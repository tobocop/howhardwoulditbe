(function (exports) {
  exports.Plink.ContestPageCfCallbacks = {
    setup: function () {
      $(document).on('cardLinkProcessComplete', this._cardLinkProcessComplete);
    },

    _cardLinkProcessComplete: function() {
      window.location.href = window.location.href + '?card_linked=true';
    }
  }
})(window);

$(function () {
  if ($("#contests-show").length){
    Plink.ContestPageCfCallbacks.setup();
  }
});

