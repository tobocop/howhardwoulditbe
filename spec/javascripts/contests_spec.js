describe('Contest', function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      ' <form action="/contests/1/toggle_opt_in_to_daily_reminder" method="post">' +
      '   <input name="authenticity_token" type="hidden" value="12345">' +
      '   <input class="checkbox" id="js-toggle-daily-email" name="daily_contest_reminder" type="checkbox" value="1" checked>' +
      ' </form>'
    );

    Contest.bindEvents();
  });

  describe('toggling daily contest reminder emails', function () {
    beforeEach(function () {
      elem = $('#js-toggle-daily-email');
    });

    it('makes an AJAX request', function (){
      spyOn($, "ajax");

      elem.trigger('click');

      expect($.ajax).toHaveBeenCalled();
    });

    it('calls to update the check box state on success', function () {
      spy = spyOn(Contest, 'setDailyEmailCheckBox');

      spyOn($, "ajax").andCallFake(function(options) {
        options.success();
      });

      elem.trigger('click');

      expect(spy).toHaveBeenCalled();
    });

    it('does not change the check box on failure', function () {
      spy = spyOn(Contest, 'setDailyEmailCheckBox');

      spyOn($, "ajax").andCallFake(function(options) {
        options.error();
      });

      elem.trigger('click');

      expect(spy).not.toHaveBeenCalled();
    });
  });

  describe('#setDailyEmailCheckBox', function () {
    it('sets state on the checkbox', function () {
      Contest.setDailyEmailCheckBox(false);
      expect(document.getElementById('js-toggle-daily-email').checked).toEqual(false);

      Contest.setDailyEmailCheckBox(true);
      expect(document.getElementById('js-toggle-daily-email').checked).toEqual(true);
    });
  })
});
