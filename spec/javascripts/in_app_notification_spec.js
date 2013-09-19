describe('Plink.InAppNotification', function () {

  var $container;

  beforeEach(function () {

    $('#jasmine_content').html(
      '<div class="in-app-note">' +
        '<img src="/assets/btn_close.png" id="contest-notification" class="close-btn" alt="Close">' +
        'Enter our contest today for your share of $1,000 in Gift Cards' +
         '<div class="btn">' +
            '<a id="contest-results" class="button primary-action" href="/contests">GO TO CONTEST</a>' +
          '</div>' +
      '</div>');

      $container = $('.in-app-note');
      Plink.InAppNotification.setup();
  });

  describe('.hideContestNotification', function () {

    it("hides the notification when the close image is clicked", function () {

      expect($container.hasClass('hidden')).toBeFalsy();

      $('.close-btn').click();

      expect($container.hasClass('hidden')).toBeTruthy();

    });

  });

  describe('.contestResultsRedirect', function() {

    it("hides the notification when the Results link is clicked", function () {

      expect($container.hasClass('hidden')).toBeFalsy();

      $('#contest-results').click();

      expect($container.hasClass('hidden')).toBeTruthy();

    });

  });

  describe('.setContestNotificationCookie', function () {

    it("calls the cookie-setting code to prevent the dialog from re-displaying", function () {

      spyOn(Plink.InAppNotification, 'setContestNotificationCookie');

      $('.close-btn').click();

      expect(Plink.InAppNotification.setContestNotificationCookie).toHaveBeenCalled();

    });

  });

});
