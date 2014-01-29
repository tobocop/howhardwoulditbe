var LandingPages = {
  toggleNewForm : function(e) {
    $('.toggle').css('display', 'none')
    toggle = $(this).data('toggle')
    $(toggle).css('display', 'block')
  }
};

// Bind events:
$(document).on('click', '.js-landing-page-type', LandingPages.toggleNewForm);
