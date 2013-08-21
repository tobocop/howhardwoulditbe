describe('Plink.ajaxRedirectForm', function () {

  var $container, request;

  beforeEach(function () {
    $('#jasmine_content').html(
      '<script type="text/handlebars-template" id="special-error-template">' +
        '<p>Im special</p>' +
        '<p>{{instructions}}</p> ' +
        '<ul> {{#each errors}} ' +
        '<li class="font error">{{this}}</li> {{/each}} ' +
        '</ul> ' +
        '</script>' +
        '<form id="registration-form" action="/registration" data-error-template-selector="#special-error-template">' +
        '<div class="error-messages"></div>' +
        '<input type="text" name="first_name" value="John" />' +
        '<input type="text" name="email" value="j@example.com" />' +
        '<input type="password" name="password" value="password"/>' +
        '<input type="password" name="password_confirmation" value="password"/>' +
        '<input type="submit" />' +
        '</form>');

    $container = $('#registration-form');
    $container.ajaxRedirectForm();
  });

  describe('form submission', function () {
    describe('when successful', function () {
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

        expect(Plink.redirect).toHaveBeenCalledWith('/foonazzle');
      });
    });

    describe('when not successful', function () {
      it('displays any errors that are returned', function () {
        spyOn(Plink, 'redirect');

        $container.find('input[type="submit"]').click();

        request = mostRecentAjaxRequest();
        request.response(TestResponses.registration.failure);

        expect($('.error-messages').html()).toContain('Im special');
        expect($('.error-messages').html()).toContain('Please correct the errors below:');
        expect($('.error-messages').html()).toContain('Please enter a First Name');
      });
    });
  });
});
