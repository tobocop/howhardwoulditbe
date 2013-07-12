(function (exports) {
  exports.Plink.GigyaShareBarWidget = {
    setup: function () {
      if ($('#share-bar-widget').length > 0) {
        var userAction = Plink.GigyaAction.create($('#share-bar-widget'))

        var params = {
          userAction: userAction,
          shareButtons: Plink.Config.enabledShareMethods,
          userAction: userAction,
          containerID: 'share-bar-widget',
          cid: ''
        };

        gigya.socialize.showShareBarUI( params );
      }
    }
  }
})(window);

$(function () {
  Plink.GigyaShareBarWidget.setup();
});
