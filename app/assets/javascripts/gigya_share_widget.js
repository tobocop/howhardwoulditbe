(function (exports) {
  exports.Plink.GigyaShareWidget = {
    setup: function () {
      $('.invite-friend-widget').on('click', this._clickHandler);
    },

    _clickHandler: function (event) {
      event.preventDefault();

      var $target = $(event.target);
      var action = new gigya.socialize.UserAction();

      action.setTitle($target.data('title'));
      action.setLinkBack($target.attr('href'));
      action.setDescription($target.data('description'));
      action.addMediaItem({ type: 'image', src: $target.data('image'), href: $target.attr('href') });

      gigya.socialize.showShareUI({  userAction: action, enabledProviders: Plink.Config.enabledProviders });
    }
  }
})(window);

$(function () {
  Plink.GigyaShareWidget.setup();
});
