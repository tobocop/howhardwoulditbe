(function (exports) {
  exports.Plink.GigyaContestShareWidget = {
    setup: function () {
      $(document).on('click', '[data-contest-share-widget]', this._clickHandler);
      $(document).on('click', '[data-contest-winner-share-widget]', this._clickHandlerWithoutErrorCallbacks);
    },

    _clickHandler: function (event) {
      $(".flash-container").empty();

      var defaultAction = Plink.GigyaAction.create(event.target),
          facebookAction = Plink.GigyaAction.create(event.target, 'facebook'),
          twitterAction = Plink.GigyaAction.create(event.target, 'twitter');

      gigya.socialize.showShareUI({
        userAction: defaultAction,
        facebookUserAction: facebookAction,
        twitterUserAction: twitterAction,
        enabledProviders: $(this).data().providers,
        onSendDone: Plink.GigyaContestShareWidget._onSendDone,
        onError: Plink.GigyaContestShareWidget._onError
      });

      return false;
    },

    _clickHandlerWithoutErrorCallbacks: function (event) {
      $(".flash-container").empty();

      var defaultAction = Plink.GigyaAction.create(event.target);
      var facebookAction = Plink.GigyaAction.create(event.target, 'facebook');
      var twitterAction = Plink.GigyaAction.create(event.target, 'twitter');

      gigya.socialize.showShareUI({
        userAction: defaultAction,
        facebookUserAction: facebookAction,
        twitterUserAction: twitterAction,
        enabledProviders: Plink.Config.enabledProviders,
        onSendDone: Plink.InAppNotification.hideContestNotification
      });

      return false;
    },

    _onError: function (e) {
      if (e.eventName === 'error' && e.statusMessage === 'Operation canceled') {
        gigya.socialize.hideUI();

        var error_msg = '<div class="flash-msg">You must accept the share dialogue to enter</div>';
        $(".flash-container").html(error_msg);
      }

      return false;
    },

    _onSendDone: function (e) {
      var url = '/contests/' + $("#contest_id").val() + '/entries',
          csrf_token_and_contest_id = $("#js-contest-entry").serialize(),
          providers = e.providers,
          post_data = csrf_token_and_contest_id + '&providers=' + providers;

      $.ajax({
        url: url,
        type: 'POST',
        data: post_data,
        dataType: 'json',
        success: function(resp) { Plink.GigyaContestShareWidget._onEntrySucess(resp); },
        error: function(xhr) { Plink.GigyaContestShareWidget._onEntryFailure(xhr); }
      });

      return false;
    },

    _onEntrySucess: function (resp) {
      gigya.socialize.hideUI();
      var entry_or_entries = resp.incremental_entries === 1 ? 'entry!' : 'entries!',
          msg = '<div class="flash-msg">You just received ' + resp.incremental_entries +
            ' additional ' + entry_or_entries + '</div>';

      $(".flash-container").html(msg);
      $("#js-contest-entries").html(resp.total_entries);

      var total_entry_or_entries = resp.total_entries === 1 ? 'entry.' : 'entries.';
      $("#js-entry-or-entries").html(total_entry_or_entries);

      Plink.GigyaContestShareWidget._updateShareButtonText(resp.button_text);
      Plink.GigyaContestShareWidget._updateEntriesSubText(resp.sub_text);
      Plink.GigyaContestShareWidget._updateProviders(resp.available_providers);

      if (resp.disable_submission) Plink.GigyaContestShareWidget._disableShareButton();
      if (resp.set_checkbox) Contest.setDailyEmailCheckBox(true);
    },

    _onEntryFailure: function (xhr) {
      gigya.socialize.hideUI();

      var response = $.parseJSON(xhr.responseText),
          errors = response.errors,
          msg = '<div class="flash-msg">' + errors + '</div>';

      $(".flash-container").html(msg);

      if (response.disable_submission) {
        Plink.GigyaContestShareWidget._disableShareButton();
      }
    },

    _updateShareButtonText: function(button_text) {
      $('#js-share-to-enter').html(button_text);
    },

    _updateEntriesSubText: function(text) {
      $('#js-entry-subtext').html(text);
    },

    _updateProviders: function (provider_list) {
      $('#js-share-to-enter').data({providers: provider_list});
    },

    _disableShareButton: function() {
      $("#js-share-to-enter").removeAttr('data-contest-share-widget');
      $("#js-share-to-enter").removeClass("white-txt");
      $("#js-share-to-enter").addClass("disabled");
      $("#js-share-to-enter").removeAttr('href');
      $("#js-share-to-enter").html('Enter tomorrow');
    },
  }
})(window);

$(function () {
  if ($("#contests-index, #contests-show, #notification-share, .in-app-note").length){
    Plink.GigyaContestShareWidget.setup();
  }
});

