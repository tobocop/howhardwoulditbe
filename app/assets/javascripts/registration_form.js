(function ($) {
  Plink.RegistrationForm = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.errorsTemplate = Handlebars.compile($('#generic-error-template').html());

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
        .done(base._successfulSubmission)
        .fail(base._failureSubmission);
    };

    base._successfulSubmission = function(data) {
      Plink.redirect(Plink.Routes.dashboard_path);
    };

    base._failureSubmission = function (xhr) {
      var response = $.parseJSON(xhr.responseText);

      var errorsHtml = base.errorsTemplate({instructions: response.error_message, errors: base._mapErrorMessages(response.errors)});

      base.$el.find('.error-messages').html(errorsHtml);
    };

    base._mapErrorMessages = function(errorMessages) {
      var messagesCollection = [];
      $.each(errorMessages, function(key, val) {
        $(val).each(function(i, item) {
          messagesCollection.push(item);
        })
      });
      return messagesCollection;
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