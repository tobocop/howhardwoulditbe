(function () {
  Contest = {
    bindEvents: function () {
      $(document).on('click', '#js-toggle-daily-email', Contest.toggleDailyEmailPreference);
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
    }
  }
})(window);

$(function () {
  var contest_pages = "#contests-index, #contests-show"

  if ($(contest_pages).length) Contest.bindEvents();
});
