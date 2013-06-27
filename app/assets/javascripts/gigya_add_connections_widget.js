(function (exports) {
  exports.Plink.GigyaAddConnectionsWidget = {
    setup: function () {
      if ($('#social-link-widget').length > 0) {
        gigya.socialize.showAddConnectionsUI({
          showTermsLink: false,
          showEditLink: true,
          hideGigyaLink: true,
          enabledProviders: Plink.Config.enabledProviders,
          containerID: 'social-link-widget',
          width: 65,
          height: 70
        });
      }
    }
  }
})(window);

$(function () {
  Plink.GigyaAddConnectionsWidget.setup();
});
