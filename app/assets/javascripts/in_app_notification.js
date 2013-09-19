(function (exports) {
  exports.Plink.InAppNotification = {
    setup: function () {
      $(document).on('click', '.in-app-note > .close-btn', this.closeInAppNotification);
      $(document).on('click', '#js-share-to-enter', this.closeInAppNotification);
      $(document).on('click', '#contest-results', this.contestResultsRedirect);
    },

    setContestNotificationCookie: function() {
      var expirationDate = new Date();
      expirationDate.setHours(24,0,0,0);
      document.cookie = 'contest_notification=' + '1' + '; expires=' + expirationDate.toGMTString() + '; path=/';
    },

    hideContestNotification: function() {
      $('.in-app-note').addClass('hidden');
    },

    contestResultsRedirect: function() {
      Plink.InAppNotification.hideContestNotification();
      Plink.InAppNotification.setContestNotificationCookie();
    },

    closeInAppNotification: function() {
      Plink.InAppNotification.hideContestNotification();
      Plink.InAppNotification.setContestNotificationCookie();
    }

  };
})(window);

$(function () {
  if ($('.in-app-note').length) {
    Plink.InAppNotification.setup();
  }
});