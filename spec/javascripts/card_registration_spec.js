describe('CardRegistration', function() {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div class="reg">' +
      '  <div class="layout-inner">' +
      '    <span class="left-column"><div class="steps first">lets get started</div>' +
      '      <div class="steps active"></div><div class="steps"></div>' +
      '    </span>' +
      '    <div class="right-column"></div>' +
      '    <a href="#" class="js-go-back">Link Me</a>' +
      '    <div id="duplicate" style="display: none">duplicate</div>' +
      '    <div id="please-login">please-login</div>' +
      '    <div class="institution-authentication-form">' +
      '      <form id="js-authentication-form" class="js-account-type-selection-form js-account-selection" action="/stuff">' +
      '        <input type="hidden" id="intuit_account_id" value="12345"/>' +
      '        <input type="submit" />' +
      '      </form>' +
      '      <form id="js-text-based-mfa-form" action="/stuff"></form>' +
      '    </div>' +
      '    <div class="close-btn js-select-a-different-account"></div>' +
      '  </div>' +
      '</div>' +
      '<div class="content-replacement"></div>' +
      '<form>' +
      '  <p id="intuit_account_id">Cool Story</p>' +
      '</form>' +
      '<input type="submit" class="account-type-selection-form"></input>' +
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

    it('binds on the submit of .js-account-selection', function () {
      spyOn(CardRegistration, 'accountSelection').andCallFake(function () {
        return true;
      });

      CardRegistration.bindEvents();
      $('.js-account-selection').trigger('submit');

      expect(CardRegistration.accountSelection).toHaveBeenCalled();
    });

    it('binds on the submit of .js-account-type-selection-form', function () {
      spyOn(CardRegistration, 'submitAccountTypeSelection').andCallFake(function () {
        return true;
      });

      CardRegistration.bindEvents();
      $(".js-account-type-selection-form").trigger('submit');

      expect(CardRegistration.submitAccountTypeSelection).toHaveBeenCalled();
    });

    it('binds on the click of .js-select-a-different-account', function () {
      spyOn(CardRegistration, 'closeModal').andCallFake(function() {
        return true;
      });

      CardRegistration.bindEvents();
      $('.js-select-a-different-account').trigger('click');

      expect(CardRegistration.closeModal).toHaveBeenCalled();
    });


    it('binds on the click .close-btn', function () {
      spyOn(CardRegistration, 'closeModal').andCallFake(function() {
        return true;
      });

      CardRegistration.bindEvents();
      $('.close-btn').trigger('click');

      expect(CardRegistration.closeModal).toHaveBeenCalled();
    });
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
    it('takes the content of #js-establishing-connection and replaces the given selector with it', function(){
      CardRegistration.showProgressBar($('.content-replacement'));

      expect($('.content-replacement span')).toEqual($('#js-establishing-connection'));
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

    it('replaces the right element of the DOM when no left column is present', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve('awesome');
        return deferred.promise();
      });

      CardRegistration.pollForAccountResponse();

      expect($('#js-establishing-connection:visible').length).toEqual(0);
      expect($('.right-column').html()).toEqual('awesome');
    });

    it('replaces the inner layout of the DOM when left column is present', function() {
      html_resp = '<div class="left-column">something</div><div class="right-column">right</div>';
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve(html_resp);
        return deferred.promise();
      });

      CardRegistration.pollForAccountResponse();

      expect($('#js-establishing-connection:visible').length).toEqual(0);
      expect($('.layout-inner').html()).toEqual(html_resp);
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
    });

    it('sets the step passed in as the active step', function() {
      CardRegistration.setActiveStep(2);
      expect($('.steps')[2]).toHaveClass('active');
    });
  });

  describe('#accountSelection', function () {
    it('calls to submitAccountForm', function () {
      spyOn(CardRegistration, 'submitAccountForm');

      CardRegistration.accountSelection();

      expect(CardRegistration.submitAccountForm).toHaveBeenCalled();
    });

    it('returns false', function () {
      expect(CardRegistration.accountSelection()).toBe(false);
    });

    describe('with an account type of other', function () {
      beforeEach(function () {
        spyOn($.fn, 'hasClass').andReturn(true);
      });

      it('grabs the intuit_account_id', function () {
        spyOn(CardRegistration, 'forwardAccountIdToTypeSelection');

        CardRegistration.accountSelection();

        expect(CardRegistration.forwardAccountIdToTypeSelection).toHaveBeenCalled();
      });

      it('calls to foundation to open a modal', function () {
        var spy = spyOn($.fn, 'foundation');

        CardRegistration.accountSelection();

        expect(spy).toHaveBeenCalledWith('reveal', 'open');
      });
    });
  });

  describe('#forwardAccountIdToTypeSelection', function () {
    it('appends the intuit_account_id to .js-account-type-selection-form', function () {
      CardRegistration.forwardAccountIdToTypeSelection($('#js-authentication-form'));

      expect($('.js-account-type-selection-form #intuit_account_id').val()).toEqual('12345');
    });
  });

  describe('#submitAccountTypeSelection', function () {
    it('calls submitAccountForm', function () {
      spyOn(CardRegistration, 'submitAccountForm');

      CardRegistration.submitAccountTypeSelection();

      expect(CardRegistration.submitAccountForm).toHaveBeenCalled();
    });

    it('returns false', function () {
      expect(CardRegistration.submitAccountTypeSelection()).toBe(false);
    });
  });

  describe('#submitAccountForm', function () {
    it('calls to foundation', function () {
      var spy = spyOn($.fn, 'foundation');

      CardRegistration.submitAccountForm($('.js-authentication-form'));

      expect(spy).toHaveBeenCalledWith('reveal', 'open');
    });

    it('makes an AJAX request to submit the form', function () {
      var def = $.Deferred();
      spyOn($, "ajax").andCallFake(function() {return def;});

      CardRegistration.submitAccountForm($('#js-authentication-form'));

      expect($.ajax).toHaveBeenCalledWith({data: '', type: 'POST', url: '/stuff'});
    });

    it('triggers pollForAccountResponse on the resolution of the AJAX request', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve();
        return deferred.promise();
      });
      spyOn(window, 'setTimeout');

      CardRegistration.submitAccountForm($('#js-authentication-form'));

      expect(window.setTimeout).toHaveBeenCalledWith(CardRegistration.pollForSelectAccountFormResponse, 3000);
    });
  });

  describe('#pollForSelectAccountFormResponse', function () {
    it('calls GET /institutions/select_account_poll via AJAX', function () {
      var def = $.Deferred();
      spyOn($, "ajax").andCallFake(function() {return def;});

      CardRegistration.pollForSelectAccountFormResponse();

      expect($.ajax).toHaveBeenCalledWith({url: '/institutions/select_account_poll', type: 'GET'});
    });

    it('calls itself on a failed AJAX request', function () {
      spyOn(window, 'setTimeout');
      spyOn($, "ajax").andCallFake(function() {
        var deferred = $.Deferred();
        deferred.reject('awesome');
        return deferred.promise();
      });

      CardRegistration.pollForSelectAccountFormResponse();

      expect(window.setTimeout).toHaveBeenCalledWith(CardRegistration.pollForSelectAccountFormResponse, 3000);
    });

    describe('with a failed response from the server', function () {
      it('calls to foundation', function () {
        var spy = spyOn($.fn, 'foundation');
        spyOn($, "ajax").andCallFake(function() {
          var deferred = $.Deferred();
          deferred.resolve({failure: true});
          return deferred.promise();
        });

        CardRegistration.pollForSelectAccountFormResponse();

        expect(spy).toHaveBeenCalledWith('reveal', 'open');
      });
    });

    describe('with a successful response from the server', function () {
      it('sets the window location', function () {
        var spy = spyOn(CardRegistration, 'setWindowLocation');
        spyOn($, "ajax").andCallFake(function() {
          var deferred = $.Deferred();
          deferred.resolve({failure: false, data: {account_name: 'Account', updated_accounts: 2}});
          return deferred.promise();
        });

        CardRegistration.pollForSelectAccountFormResponse();

        expect(spy).toHaveBeenCalledWith('/institutions/congratulations?account_name=Account&updated_accounts=2');
      });
    });
  });

  describe('#closeModal', function () {
    it('calls foundation to close any open modals', function () {
      var spy = spyOn($.fn, 'foundation');

      expect(CardRegistration.closeModal()).toBe(false);
    });

    it('returns false', function () {
      var spy = spyOn($.fn, 'foundation');

      CardRegistration.closeModal();

      expect(spy).toHaveBeenCalledWith('reveal', 'close');
    });
  });
});
