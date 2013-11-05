describe('CardRegistration', function() {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<span class="right-column"></span>' +
      '<a href="#" class="js-go-back">Link Me</a>' +
      '<div class="institution-authentication-form">' +
      '  <form id="js-authentication-form" action="/stuff">' +
      '  <input type="text" name="email" value="j@example.com" />' +
      '  <input type="password" name="password" value="password"/>' +
      '  <input type="submit" />' +
      '  </form>' +
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

    xit('Triggering a click of the back button causes the spec suite to go back...');
  });

  describe('#submitForm', function() {
    it('calls showProgressBar', function() {
      spyOn(CardRegistration, 'showProgressBar');

      CardRegistration.submitForm();

      expect(CardRegistration.showProgressBar).toHaveBeenCalled();
    });

    it('posts the form via AJAX', function() {
      var def = $.Deferred();
      spyOn($, "ajax").andCallFake(function() {return def;});

      CardRegistration.submitForm();

      expect($.ajax).toHaveBeenCalled();
    });

    it('triggers pollForAccountResponse', function() {
      spyOn($, 'ajax').andCallFake(function() {
        var deferred = $.Deferred();
        deferred.resolve();
        return deferred.promise();
      });
      spyOn(CardRegistration, 'pollForAccountResponse');

      CardRegistration.submitForm();

      expect($('.institution-authentication-form span')).toEqual($('#js-establishing-connection'));
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
});
