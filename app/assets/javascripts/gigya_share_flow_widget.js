(function (exports) {
  exports.Plink.GigyaShareFlowWidget = {
    setup: function () {
      $(document).on('click', '[data-facebook-share-flow-share-widget]', this._clickHandler);
    },

    _clickHandler: function (event) {
      event.preventDefault();

      var action = Plink.GigyaAction.create(event.target),
          url = $('#js-update-share-tracking-url').val();

      gigya.socialize.showShareUI({
        userAction: action,
        enabledProviders: Plink.Config.enabledProviders,
        onSendDone: function() { Plink.GigyaShareFlowWidget._onSendDone(url); }
      });
    },

    _onSendDone: function (share_status_url) {
      $.ajax({
        url: share_status_url,
        data: {shared: true}
      }).done(Plink.GigyaShareFlowWidget.redirectToWalletWithLinkCardModal);
    },

    redirectToWalletWithLinkCardModal: function() {
      Plink.redirect('/wallet?link_card=true');
    }
  }
})(window);

$(function () {
  Plink.GigyaShareFlowWidget.setup();
});
