describe('CardRegistration', function() {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<span class="right-column"><div class="steps first">lets get started</div>' +
      '  <div class="steps active"></div><div class="steps"></div>' +
      '</span>' +
      '<a href="#" class="js-go-back">Link Me</a>' +
      '<div id="duplicate" style="display: none">duplicate</div>' +
      '<div id="please-login">please-login</div>' +
      '<div class="js-all-fields-required">derp</div>' +
      '<div class="institution-authentication-form">' +
      '  <form id="js-authentication-form" action="/stuff">' +
      '    <input type="submit" />' +
      '  </form>' +
      '  <form id="js-text-based-mfa-form" action="/stuff"></form>' +
      '</div>' +
      '<span id="js-establishing-connection">Connecting</span>'
    );
  });

  describe('#bindEvents', function() {
    it('binds on the submission of #js-authentication-form', function() {
      spyOn(CardRegistration, 'submitForm').andCallFake(function(){
        return false;
      });

      CardRegistration.bindEvents();

      $("#js-authentication-form").trigger('submit');

      expect(CardRegistration.submitForm).toHaveBeenCalled();
    });

    it('binds on the submission of #js-text-based-mfa-form', function() {
      spyOn(CardRegistration, 'submitForm').andCallFake(function(){
        return false;
      });

      CardRegistration.bindEvents();

      $("#js-text-based-mfa-form").trigger('submit');

      expect(CardRegistration.submitForm).toHaveBeenCalled();
    });

    xit('Triggering a click of the back button causes the spec suite to go back...');
  });

  describe('#submitForm', function() {
    beforeEach(function() {
      $('#jasmine_content').append('<input class="required" type="text" name="email" value="j@example.com" />');
    });

    it('posts the form via AJAX', function() {
      spyOn(CardRegistration, 'requiredFieldsPresent').andCallFake(function() { return true; });
      var def = $.Deferred();
      spyOn($, "ajax").andCallFake(function() {return def;});

      CardRegistration.submitForm();

      expect($.ajax).toHaveBeenCalled();
    });

    it('calls showProgressBar on a successful ajax response', function() {
      spyOn(CardRegistration, 'requiredFieldsPresent').andCallFake(function() { return true; });
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve();
        return deferred.promise();
      });
      spyOn(CardRegistration, 'showProgressBar');

      CardRegistration.submitForm();

      expect(CardRegistration.showProgressBar).toHaveBeenCalled();
    });

    it('triggers pollForAccountResponse on a successful ajax response', function() {
      spyOn(CardRegistration, 'requiredFieldsPresent').andCallFake(function() { return true; });
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve();
        return deferred.promise();
      });
      spyOn(window, 'setTimeout');

      CardRegistration.submitForm();

      expect(window.setTimeout).toHaveBeenCalledWith(CardRegistration.pollForAccountResponse, 3000);
    });

    it('displays duplicate account messaging if the response is a failure', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.reject('awesome');
        return deferred.promise();
      });

      CardRegistration.submitForm();

      expect($('#duplicate:visible').length).toEqual(1);
      expect($('#please-login:visible').length).toEqual(0);
      expect($('.js-all-fields-required:visible').length).toEqual(0);
    });

    it('validates that required fields have values', function() {
      spyOn(CardRegistration, 'requiredFieldsPresent');

      CardRegistration.submitForm();

      expect(CardRegistration.requiredFieldsPresent).toHaveBeenCalled();
    });

    it('returns false when there are missing required fields', function() {
      spyOn(CardRegistration, 'requiredFieldsPresent').andCallFake(function() { return false; });

      expect(CardRegistration.submitForm()).toBe(false);
    });
  });

  describe('#showProgressBar', function() {
    it('substitutes the contents of the authentication form with #js-establishing-connection', function () {
      CardRegistration.showProgressBar();

      expect($('.institution-authentication-form span')).toEqual($('#js-establishing-connection'));
    });
  });

  describe('#pollForAccountResponse', function() {
    it('makes an AJAX request', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve('awesome');
        return deferred.promise();
      });

      CardRegistration.pollForAccountResponse();

      expect($.ajax).toHaveBeenCalledWith({url: '/institutions/poll', type: 'GET'});
    });

    it('replaces elements of the DOM when successful', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve('awesome');
        return deferred.promise();
      });

      CardRegistration.pollForAccountResponse();

      expect($('#js-establishing-connection:visible').length).toEqual(0);
      expect($('.right-column').html()).toEqual('awesome');
    });

    it('calls itself if the response is a failure', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.reject('awesome');
        return deferred.promise();
      });
      spyOn(window, 'setTimeout');

      CardRegistration.pollForAccountResponse();

      expect(window.setTimeout).toHaveBeenCalledWith(CardRegistration.pollForAccountResponse, 3000);
    });
  });

  describe('#requiredFieldsPresent', function() {
    it('removes existing error messages from required fields', function() {
      var additional_html = '<input class="required" type="text" name="email" value=" " /><div class="mts font-darkred">Remove me</div>';
      $('#jasmine_content').append(additional_html);
      spyOn(CardRegistration, 'findBlankFields').andCallFake(function(){ return []; });

      CardRegistration.requiredFieldsPresent();

      expect($('.mts.font-darkred').html()).toEqual('');
    });

    it('returns false if any required field is blank', function() {
      $('#jasmine_content').append('<input class="required" type="text" name="email" value=" " />');

      spyOn(CardRegistration, 'findBlankFields').andCallFake(function(){ return $('.required'); });

      expect(CardRegistration.requiredFieldsPresent()).toBe(false);
    });

    it('returns true if every required field is present', function() {
      spyOn(CardRegistration, 'findBlankFields').andCallFake(function(){ return []; });

      expect(CardRegistration.requiredFieldsPresent()).toBe(true);
    });
  });

  describe('#findBlankFields', function() {
    it('returns an empty collection if there are no blank fields', function() {
      var additional_html = '<div class="stuff"><input class="required" type="text" name="email" value="allthebest" /></div>';
      $('#jasmine_content').append(additional_html);

      expect(CardRegistration.findBlankFields($('.stuff .required'))).toEqual([]);
    });

    it('returns a collection of blank fields', function() {
      var additional_html = '<div class="stuff"><input class="required" type="text" name="email" value=" " />' +
        '<input class="required" type="text" name="email_2" value="allthebest" /></div>';
      $('#jasmine_content').append(additional_html);

      expect(CardRegistration.findBlankFields($('.stuff .required')).length).toEqual(1);
    });
  });

  describe('#updateFieldsWithErrors', function() {
    it('adds an error message to each of the provided fields', function() {
      var additional_html = '<div><input class="required" type="text" name="email" value=" " />' +
        '<input class="required" type="text" name="email_2" value="allthebest" /><div class="font-darkred"></div></div>';
      $('#jasmine_content').append(additional_html);

      CardRegistration.updateFieldsWithErrors($('.required'));

      expect($('div div .font-darkred').html()).toEqual('Please complete this field');
    });

    it('adds an error class to the "All fields required" text', function() {
      var additional_html = '<div class="js-all-fields-required"><input class="required" type="text" name="email_2" value="allthebest" /><div class="font-darkred"></div></div>';
      $('#jasmine_content').append(additional_html);

      CardRegistration.updateFieldsWithErrors($('.required'));

      expect($('.js-all-fields-required').hasClass('font-darkred')).toBe(true);
    });
  });

  describe('#setActiveStep', function() {
    it('removes the active class from all existing steps', function() {
      CardRegistration.setActiveStep();
      expect($('.active').length).toEqual(0);
    })

    it('sets the step passed in as the active step', function() {
      CardRegistration.setActiveStep(2);
      expect($('.steps')[2]).toHaveClass('active');
    })
  })
});
