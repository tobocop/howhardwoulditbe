(function ($) {
  Plink.RegistrationForm = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base.bindEvents();
    };

    base.bindEvents = function () {
      base.$el.on('submit', base._handleFormSubmit);
    };

    base._handleFormSubmit = function(e) {
      e.preventDefault();
      var url = $(e.currentTarget).attr('action');
      base._submit(url);
    };

    base._submit = function(url) {
      var formValues = base._getFormValues();
      $.ajax({
        url: url,
        data: formValues,
        method: 'post'
      })
        .done(base._successfulSubmission);
    };

    base._successfulSubmission = function(data) {
      Plink.redirect(Plink.Routes.dashboard_path);
    };

    base._getFormValues = function() {
      return {
        first_name: base.$el.find('input[name="first_name"]').val(),
        email: base.$el.find('input[name="email"]').val(),
        password: base.$el.find('input[name="password"]').val(),
        password_confirmation: base.$el.find('input[name="password_confirmation"]').val()
      }
    };

    base.init();
  };

  Plink.RegistrationForm.defaultOptions = {

  };

  $.fn.registrationForm = function (options) {
    return this.each(function () {
      (new Plink.RegistrationForm(this, options));
    });
  };

})(jQuery);