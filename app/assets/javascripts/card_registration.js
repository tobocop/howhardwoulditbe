(function () {
  CardRegistration = {
    bindEvents: function () {
      $(document).on('submit', '#js-authentication-form', CardRegistration.submitForm);
      $(document).on('submit', '#js-text-based-mfa-form', CardRegistration.submitForm);
      $(document).on('click', '.js-go-back', CardRegistration.triggerBrowserBack);
    },

    submitForm: function (e) {
      var selector = $(this).find('.form-container > input.form-field');
      if ( !CardRegistration.requiredFieldsPresent(selector) ) return false;

      var $form = $(this);
      $.ajax({
        data: $form.serialize(),
        type: 'POST',
        url: $form.attr('action')
      }).done(function() {
        CardRegistration.showProgressBar();
        setTimeout(CardRegistration.pollForAccountResponse, 3000);
      }).fail(function() {
        $('#duplicate').show();
        $('#please-login').hide();
        $('.js-all-fields-required').hide();
      });

      return false;
    },

    showProgressBar: function () {
      var $progress_bar = $("#js-establishing-connection");
      $(".institution-authentication-form").html($progress_bar.show());
    },

    pollForAccountResponse: function() {
      $.ajax({
        url: '/institutions/poll',
        type: 'GET'
      }).done(function(resp) {
        $('.progress-bar').html($('#js-establishing-connection').hide());
        if(resp.indexOf('left-column') > 0){
          $('.reg .layout-inner').html(resp);
        } else {
          $('.right-column').html(resp);
        }
      }).fail(function() {
        setTimeout(CardRegistration.pollForAccountResponse, 3000);
      });
    },

    redirectToSuccessPath: function(path) {
      window.location = path;
    },

    triggerBrowserBack: function(e) {
      window.history.back();

      return false;
    },

    requiredFieldsPresent: function(selector) {
      var missing_fields = CardRegistration.findBlankFields(selector);
      $('.mts.font-darkred').html('');

      if (missing_fields.length) {
        CardRegistration.updateFieldsWithErrors(missing_fields);
        return false;
      } else {
        return true;
      }
    },

    findBlankFields: function(selector) {
      var blank_fields = [];

      selector.each(function(index){
        var $this = $(this);
        if (!$this.val() || $this.val().trim().length === 0) {
          blank_fields.push($this);
        }
      })

      return blank_fields;
    },

    updateFieldsWithErrors: function(fields) {
      $.each(fields, function(index){
        $(this).parent().find($('.font-darkred')).html('Please complete this field');
      });

      $('.js-all-fields-required').addClass('font-darkred');
    },

    setActiveStep: function(stepNumber) {
      $('.steps').removeClass('active');
      $('.steps').slice(stepNumber, stepNumber + 1).addClass('active');
    }
  }
})(window);

$(function () {
  var card_registration = "#institutions-authentication";

  if ($(card_registration).length) {
    CardRegistration.bindEvents();
  }
});
