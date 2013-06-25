(function (exports) {
  exports.Plink.GigyaShareWidget = {
    setup: function () {
      $('.invite-friend-widget').on('click', this._clickHandler);
    },

    _clickHandler: function (event) {
      event.preventDefault();

      var action = Plink.GigyaAction.create(event.target);
      gigya.socialize.showShareUI({  userAction: action, enabledProviders: Plink.Config.enabledProviders });
    }
  }
})(window);

$(function () {
  Plink.GigyaShareWidget.setup();
});
