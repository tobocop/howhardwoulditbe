(function () {
  CardRegistration = {
    bindEvents: function () {
      $(document).on('submit', '#js-authentication-form', CardRegistration.submitForm);
      $(document).on('submit', '#js-text-based-mfa-form', CardRegistration.submitForm);
      $(document).on('click', '.js-go-back', CardRegistration.triggerBrowserBack);
      $(document).on('submit', '.js-account-selection', CardRegistration.accountSelection);
      $(document).on('submit', '.js-account-type-selection-form', CardRegistration.submitAccountTypeSelection);
      $(document).on('click', '.js-select-a-different-account', CardRegistration.closeModal);
      $(document).on('click', '.close-btn', CardRegistration.closeModal);
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
        CardRegistration.showProgressBar($(".institution-authentication-form"));
        CardRegistrationGA.firstCommunicatingScreen();
        setTimeout(CardRegistration.pollForAccountResponse, 3000);
      }).fail(function() {
        $('#duplicate').show();
        $('#please-login').hide();
        $('.js-all-fields-required').hide();
      });

      return false;
    },

    showProgressBar: function (selector) {
      var $progress_bar = $("#js-establishing-connection");
      selector.html($progress_bar.show());
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
    },

    accountSelection: function (e) {
      if ($(this).hasClass('account-type-other')) {
        CardRegistration.forwardAccountIdToTypeSelection($(this));
        $('#account-type-other').foundation('reveal', 'open');
      } else {
        CardRegistration.submitAccountForm($(this));
      }
      return false;
    },

    forwardAccountIdToTypeSelection: function (form) {
      var account = form.find('#intuit_account_id').clone();
      $('.js-account-type-selection-form').append(account);
    },

    submitAccountTypeSelection: function (e) {
      CardRegistration.submitAccountForm($(this));

      return false;
    },

    submitAccountForm: function (form) {
      $('#account-checking-compatability').foundation('reveal', 'open');
      CardRegistrationGA.secondCommunicatingScreen();

      $.ajax({
        data: form.serialize(),
        type: 'POST',
        url: form.attr('action')
      }).done(function() {
        setTimeout(CardRegistration.pollForSelectAccountFormResponse, 3000);
      });
    },

    pollForSelectAccountFormResponse: function () {
      $.ajax({
        url: '/institutions/select_account_poll',
        type: 'GET'
      }).done(function(resp){
        if( resp.failure ) {
          $('#account-selection-failure').foundation('reveal', 'open');
        } else {
          var query_params =  'account_name=' + encodeURIComponent(resp.data.account_name) + '&updated_accounts=' + encodeURIComponent(resp.data.updated_accounts);
          CardRegistration.setWindowLocation('/institutions/congratulations?' + query_params);
        }
      }).fail(function() {
        setTimeout(CardRegistration.pollForSelectAccountFormResponse, 3000);
      });
    },

    closeModal: function (e) {
      $(document).foundation('reveal', 'close');

      return false;
    },

    setWindowLocation: function (url) {
      window.location = url;
    }
  }
})(window);

$(function () {
  var card_registration = "#institutions-authentication";

  if ($(card_registration).length) {
    CardRegistration.bindEvents();
  }
});
