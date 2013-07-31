(function($) {
  $.fn.disableOnClick = function() {
    var $el = $(this);

    $el.click(function(e) {
      if ($el.hasClass('disabled')) {
        e.preventDefault();
        e.stopPropagation();
      } else {
        $el.addClass('disabled').attr('disabled', 'disabled');
      }
    });
  }
})(jQuery);
