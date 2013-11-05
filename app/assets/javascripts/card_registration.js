(function () {
  CardRegistration = {
    bindEvents: function () {
      $(document).on('submit', '#js-authentication-form', CardRegistration.submitForm);
      $(document).on('click', '.js-go-back', CardRegistration.triggerBrowserBack);
    },

    submitForm: function (e) {
      CardRegistration.showProgressBar();

      var $form = $(this);
      $.ajax({
        data: $form.serialize(),
        type: 'POST',
        url: $form.attr('action')
      }).always(function() {
        setTimeout(CardRegistration.pollForAccountResponse, 3000);
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
        $('.right-column').html(resp);
      }).fail(function() {
        setTimeout(CardRegistration.pollForAccountResponse, 3000);
      });
    },

    triggerBrowserBack: function(e) {
      window.history.back();

      return false;
    }
  }
})(window);

$(function () {
  var card_registration = "#institutions-authentication";

  if ($(card_registration).length) {
    CardRegistration.bindEvents();
  }
});
