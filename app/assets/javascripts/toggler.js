(function ($) {
  $.fn.toggler = function() {
    var $trigger = $(this);
    $trigger.on('click', function(e) {
      e.preventDefault();

      var $target = $($(this).data('toggle-selector'));

      if ($target.hasClass('hidden')) {
        $target.removeClass('hidden');
      } else {
        $target.addClass('hidden');
      }
    });
  };
})(jQuery);