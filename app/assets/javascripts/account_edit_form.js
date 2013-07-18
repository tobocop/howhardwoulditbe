(function ($) {
  Plink.AccountEditForm = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.init = function () {
      base._collapse();
      base.bindEvents();
    };

    base.bindEvents = function () {
      base.$el.on('click', '[data-toggleable-selector]', base._handleToggle);
      base.$el.on('click', '[data-cancel]', base._handleCancel);
      base.$el.on('submit', 'form', base._handleSubmit);
    };

    base._handleToggle = function (e) {
      e.preventDefault();

      if (base._isExpanded()) {
        base._collapse();
      } else {
        base._expand();
      }
    };

    base._handleCancel = function (e) {
      e.preventDefault();

      base._collapse();
    };

    base._handleSubmit = function (e) {
      e.preventDefault();

      var $form = $(e.currentTarget);
      var url = $form.attr('action');
      var formFields = $form.serialize();

      base._submit(url, formFields);
    };

    base._isExpanded = function () {
      return base.$el.hasClass('expanded');
    };

    base._expand = function () {
      base.$el.removeClass('collapsed').addClass('expanded');
    };

    base._collapse = function () {
      base.$el.addClass('collapsed').removeClass('expanded');
    };

    base._submit = function (url, data) {
      $.ajax(url, {
        data: data,
        method: 'put'
      })
        .done(base._refreshDisplay)
        .fail(base._displayErrors)
    };

    base._refreshDisplay = function (data) {
      for (prop in data) {
        var $el = base.$el.find('[data-display-value=' + prop + ']');
        $el.text(data[prop]);
      }

      base._collapse();
    }

    base._displayErrors = function(xhr) {
      var responseData = $.parseJSON(xhr.responseText);
      var template = $("#account-error-template").html();
      var compiledTemplate = Handlebars.compile(template);

      base.$el.find('.error-messages').html(compiledTemplate({instructions: responseData.error_message, errors: responseData.errors}));
    };

    base.init();
  };

  Plink.AccountEditForm.defaultOptions = {

  };

  $.fn.accountEditForm = function (options) {
    return this.each(function () {
      (new Plink.AccountEditForm(this, options));
    });
  };

})(jQuery);