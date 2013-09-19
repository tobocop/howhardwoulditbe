(function (exports) {
  exports.Plink.CFCallbacks = {
    cardLinkProcessComplete: function () {
      $(document).trigger('cardLinkProcessComplete');
    }
  };
})(window);
