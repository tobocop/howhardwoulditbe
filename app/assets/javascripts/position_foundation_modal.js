(function ($) {
  $.fn.positionFoundationModal = function (options) {
    $(this).on('click', options.selector, function(e) {
      var $target = $(e.currentTarget);
      var $targetEl = $('#' + $target.data('reveal-id'));

      var offset = $(window).scrollTop();

      $targetEl.css({top: offset + 100});
    });
  }
})(jQuery);