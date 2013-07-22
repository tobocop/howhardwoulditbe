(function ($) {
  Plink.AccountEditForm = function (el, options) {
    var base = this;

    base.$el = $(el);

    base.errorsTemplate = Handlebars.compile($('#generic-error-template').html());

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

      Plink.Notice.display('Account updated successfully');

      base._clearInputs();
      base._clearErrors();
      base._collapse();
    };

    base._clearInputs = function() {
      base.$el.find('input[type="text"], input[type="password"]').val('');
    };

    base._clearErrors = function() {
      base.$el.find('.error-messages').html('');
    };

    base._displayErrors = function(xhr) {
      var responseData = $.parseJSON(xhr.responseText);
      base.$el.find('.error-messages').html(base.errorsTemplate({instructions: responseData.error_message, errors: base._mapErrorMessages(responseData.errors)}));
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