(function ($) {
  $.fn.toggler = function() {
    var $trigger = $(this);
    var $target = $($trigger.data('toggle-selector'));

    $trigger.on('click', function(e) {
      if ($target.hasClass('hidden')) {
        $target.removeClass('hidden');
      } else {
        $target.addClass('hidden');
      }
    });
  };
})(jQuery);