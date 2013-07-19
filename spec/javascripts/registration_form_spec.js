describe('Plink.registrationForm', function () {

  var $container, request;

  beforeEach(function () {
    $('#jasmine_content').html('<form id="registration-form" action="/registration">' +
      '<input type="text" name="first_name" value="John" />' +
      '<input type="text" name="email" value="j@example.com" />' +
      '<input type="password" name="password" value="password"/>' +
      '<input type="password" name="password_confirmation" value="password"/>' +
      '<input type="submit" />' +
      '</form>');

    $container = $('#registration-form');
    $container.registrationForm();
  });

  describe('form submission', function() {
    it("submits via ajax", function () {
      spyOn(Plink, 'redirect');

      $container.find('input[type="submit"]').click();

      request = mostRecentAjaxRequest();
      request.response(TestResponses.registration.success);

      expect(request.url).toEqual('/registration');

      expect(request.data()).toEqual({
        first_name: ['John'],
        email: ['j@example.com'],
        password: ['password'],
        password_confirmation: ['password']
      });

      expect(Plink.redirect).toHaveBeenCalledWith('/dashboard');
    });
  });
});
