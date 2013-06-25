(function (exports) {
  exports.Plink.GigyaAction = {
    create: function(element) {
      $element = $(element);
      var action = new gigya.socialize.UserAction();

      action.setTitle($element.data('title'));
      action.setLinkBack($element.attr('href'));
      action.setDescription($element.data('description'));
      action.addMediaItem({ type: 'image', src: $element.data('image'), href: $element.attr('href') });

      return action;
    }
  }
})(window);
