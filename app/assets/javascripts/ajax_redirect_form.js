(function ($) {
  Plink.AjaxRedirectForm = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base.bindEvents();
      base.errorsTemplate = base._getErrorsTemplate();
      base.redirectUrl = base.$el.data('redirect-url');
    };

    base.bindEvents = function () {
      base.$el.on('submit', base._handleFormSubmit);
    };

    base._getErrorsTemplate = function() {
      var $errorTemplate = $(base.$el.data('error-template-selector'));
      if ($errorTemplate.length <= 0) {
        $errorTemplate = $('#generic-error-template');
      }

      return Handlebars.compile($errorTemplate.html())
    };

    base._handleFormSubmit = function(e) {
      e.preventDefault();
      var url = $(e.currentTarget).attr('action'),
          submit = base.$el.find(':submit');

      submit.attr("disabled", true);
      submit.addClass("disabled");
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
      Plink.redirect(data.redirect_path);
    };

    base._failureSubmission = function (xhr) {
      var response = $.parseJSON(xhr.responseText);

      var errorsHtml = base.errorsTemplate({instructions: response.error_message, errors: base._mapErrorMessages(response.errors)}),
          submit = base.$el.find(':submit');

      submit.removeClass("disabled");
      submit.attr("disabled", false);
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
      var attributes = {};
      base.$el.find('input[type="text"], input[type="password"]').each(function(i, el) {
        var $el = $(el);
        attributes[$el.attr('name')] = $el.val();
      });
      return attributes;
    };

    base.init();
  };

  Plink.AjaxRedirectForm.defaultOptions = {

  };

  $.fn.ajaxRedirectForm = function (options) {
    return this.each(function () {
      (new Plink.AjaxRedirectForm(this, options));
    });
  };

})(jQuery);
