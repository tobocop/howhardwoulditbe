(function (exports) {
  exports.Plink.GigyaShareFlowWidget = {
    setup: function () {
      $('[data-facebook-share-flow-share-widget]').on('click', this._clickHandler);
    },

    _clickHandler: function (event) {
      event.preventDefault();

      var action = Plink.GigyaAction.create(event.target);
      gigya.socialize.showShareUI({
        userAction: action,
        enabledProviders: Plink.Config.enabledProviders,
        onSendDone: Plink.GigyaShareFlowWidget._onSendDone
      });
    },

    _onSendDone: function () {
      document.location.href = '/wallet?link_card=true';
    }
  }
})(window);

$(function () {
  Plink.GigyaShareFlowWidget.setup();
});
