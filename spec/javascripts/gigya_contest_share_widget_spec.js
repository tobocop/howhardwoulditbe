describe('Plink.GigyaContestShareWidget', function () {

  beforeEach(function () {
    window.gigya = {
      socialize: {
        showShareUI: function() {},
        hideUI: function () {}
      }
    };

    $('#jasmine_content').html('<div class="flash-container"></div>' +
      '<div data-contest-share-widget="true"></div>' +
      '<div id="js-contest-entries"></div>' +
      '<div id="js-entry-or-entries"></div>' +
      '<a id="js-share-to-enter"></a>' +
      '<div id="js-entry-subtext"></div>' +
      '<input class="checkbox" id="js-toggle-daily-email" name="daily_contest_reminder" type="checkbox" value="1" checked>' +
      '<a href="/dummy" id="js-share-to-enter" data-contest-share-widget="true" class="white-txt">Share to Enter</a>' +
      '<a href="/dummy" data-contest-winner-share-widget="true" class="white-txt">Share to Enter As a Winner</a>' +
      '<form id="js-contest-entry" style="display:none;"><input type="hidden" value="1234" name="contest_id" id="contest_id"><input name="authenticity_token" type="hidden" value="abcde"></form>'
      );
    spy = spyOn(Plink.GigyaContestShareWidget, '_cardLinkProcessComplete');
  });

  describe('#setup', function () {
    it('initializes the click handler on the right element', function () {
      spyOn(Plink.GigyaAction, 'create').andReturn('widget');
      spyOn(gigya.socialize, 'showShareUI');

      Plink.GigyaContestShareWidget.setup();

      $('[data-contest-share-widget]').trigger('click');

      var expected_params = {
        userAction: 'widget',
        facebookUserAction: 'widget',
        twitterUserAction: 'widget',
        enabledProviders: 'facebook,twitter',
        onSendDone: Plink.GigyaContestShareWidget._onSendDone,
        onError: Plink.GigyaContestShareWidget._onError
      };

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalledWith(expected_params);

      $('[data-contest-winner-share-widget]').trigger('click');

      var expected_params = {
        userAction: 'widget',
        facebookUserAction: 'widget',
        twitterUserAction: 'widget',
        enabledProviders: 'facebook,twitter',
        onSendDone: Plink.InAppNotification.hideContestNotification
      };

      expect(window.gigya.socialize.showShareUI).toHaveBeenCalledWith(expected_params);
    });

    it('initializes a handler for cardLinkProcessComplete', function() {
      Plink.GigyaContestShareWidget.setup();
      $(document).trigger('cardLinkProcessComplete');
      expect(spy).toHaveBeenCalled();
    });
  });

  describe('#_onError',  function () {
    it('returns false', function () {
      expect(Plink.GigyaContestShareWidget._onError({eventName: 'anything'})).toBe(false);
    });

    it('hides the socialize UI', function() {
      spyOn(gigya.socialize, 'hideUI');
      Plink.GigyaContestShareWidget._onError({eventName:'error', statusMessage: 'Operation canceled'});
      expect(window.gigya.socialize.hideUI).toHaveBeenCalled();
    });

    it('adds a flash error message', function() {
      Plink.GigyaContestShareWidget._onError({eventName:'error', statusMessage: 'Operation canceled'});
      expect($('.flash-container').html()).toBe('<div class="flash-msg">You must accept the share dialogue to enter</div>');
    });
  });

  describe('#_onSendDone',  function () {
    it('makes an AJAX request to create contest entries', function () {
      spyOn($, "ajax")

      Plink.GigyaContestShareWidget._onSendDone({providers: 'twitter'})

      var expected_params = {
        url: '/contests/1234/entries',
        type: 'POST',
        data: 'contest_id=1234&authenticity_token=abcde&providers=twitter',
        dataType: 'json',
        success: jasmine.any(Function),
        error: jasmine.any(Function)
      };

      expect($.ajax).toHaveBeenCalledWith(expected_params);
    });
  });

  describe('#_onEntrySucess',  function () {
    it('hides the socialize UI', function() {
      spyOn(gigya.socialize, 'hideUI');

      Plink.GigyaContestShareWidget._onEntrySucess({});

      expect(window.gigya.socialize.hideUI).toHaveBeenCalled();
    });

    it('populates the flash message with a singular success message', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({incremental_entries: 1});
      expect($('.flash-container').html()).toBe('<div class="flash-msg">You just received 1 additional entry!</div>');
    });

    it('populates the flash message with a plural success message', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({incremental_entries: 2});
      expect($('.flash-container').html()).toBe('<div class="flash-msg">You just received 2 additional entries!</div>');
    });

    it('updates the total contest entries', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({total_entries: 134});
      expect($("#js-contest-entries").html()).toBe('134')
    });

    it('updates to "1 entry." when appropriate', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({total_entries: 1});
      expect($("#js-entry-or-entries").html()).toBe('entry.')
    });

    it('updates to "X entries" when appropriate', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({total_entries: 100});
      expect($("#js-entry-or-entries").html()).toBe('entries.')
    });

    it('calls disable if disable_submission is true', function() {
      spyOn(Plink.GigyaContestShareWidget, "_disableShareButton");

      Plink.GigyaContestShareWidget._onEntrySucess({disable_submission: true});

      expect(Plink.GigyaContestShareWidget._disableShareButton).toHaveBeenCalled();
    });

    it('changes the button text according to the server\'s response', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({button_text: 'You Win'});
      expect($('#js-share-to-enter').html()).toBe('You Win');
    });

    it('changes the entries sub-text according to the server\'s response', function() {
      Plink.GigyaContestShareWidget._onEntrySucess({sub_text: 'You lose'});
      expect($("#js-entry-subtext").html()).toBe('You lose');
    });

    it('updates the checkbox if the server response indicates it should happen', function() {
      $('#js-toggle-daily-email').prop('checked', false);

      Plink.GigyaContestShareWidget._onEntrySucess({set_checkbox: true});

      expect(document.getElementById('js-toggle-daily-email').checked).toBe(true);
    });
  });

  describe('#_onEntryFailure',  function () {
    it('hides the socialize UI', function() {
      spyOn(gigya.socialize, 'hideUI');
      Plink.GigyaContestShareWidget._onEntryFailure({responseText: '{"errors": "This is an error message"}'});
      expect(window.gigya.socialize.hideUI).toHaveBeenCalled();
    });

    it('populates a flash message indicating the failure', function () {
      Plink.GigyaContestShareWidget._onEntryFailure({responseText: '{"errors": "This is an error message"}'});
      expect($('.flash-container').html()).toBe('<div class="flash-msg">This is an error message</div>');
    });

    it('calls disable if disable_submission is true', function() {
      spyOn(Plink.GigyaContestShareWidget, "_disableShareButton");

      Plink.GigyaContestShareWidget._onEntryFailure({responseText: '{"errors": "This is an error message", "disable_submission": "true"}'});

      expect(Plink.GigyaContestShareWidget._disableShareButton).toHaveBeenCalled();
    });
  });

  describe('#_disableShareButton',  function () {
    it('disables the share button', function(){
      Plink.GigyaContestShareWidget._disableShareButton()
      expect($("#js-share-to-enter").attr('data-contest-share-widget')).toBe(undefined);
      expect($("#js-share-to-enter").attr('class')).toBe('disabled');
      expect($("#js-share-to-enter").attr('href')).toBe(undefined);
      expect($("#js-share-to-enter").html()).toBe("Enter tomorrow")
    });
  });

  describe('#__cardLinkProcessComplete', function () {
    // this is pending because the refresh messes up jasmine
    xit('refreshes the page with card_linked=true');
  });

});
