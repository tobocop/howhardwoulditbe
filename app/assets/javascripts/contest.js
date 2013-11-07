(function () {
  Contest = {
    bindEvents: function () {
      $(document).on('click', '#js-toggle-daily-email', Contest.toggleDailyEmailPreference);
      $(document).on('click', '.js-complete-registration', Contest.showCardAddModal);
    },

    toggleDailyEmailPreference: function (e) {
      var checked = this.checked,
          form = $(this).closest('form'),
          data = form.serialize() + '&daily_contest_reminder=' + checked;

      $.ajax({
        url: form.prop('action'),
        type: 'POST',
        data: data,
        success: function (resp){
          Contest.setDailyEmailCheckBox(checked);
        }
      });

      return false;
    },

    setDailyEmailCheckBox: function (checked) {
      $('#js-toggle-daily-email').prop('checked', checked);
    },

    showShareModal: function() {
      Plink.conditionalCallback(
        window.location.search.match(/share_modal=true/),
        function () {
          $('#contest_share_modal').foundation('reveal', 'open');
        }
      );
    },

    showCardAddModal: function() {
      $('#card-add-modal').foundation('reveal', 'open');
    }
  }
})(window);

$(function () {
  var contest_pages = "#contests-index, #contests-show"

  if ($(contest_pages).length) {
    Contest.bindEvents();
    Contest.showShareModal();
    Plink.InAppNotification.closeInAppNotification();
  }
});
