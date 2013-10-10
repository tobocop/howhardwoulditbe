var RegistrationLinks = {
  toggleNewForm : function(e) {
    $('.alert-box').addClass('hidden');
    $('.no-flow-selected').addClass('hidden');

    var flow_type = $(this).val(),
        all_values = $.map($(".js-flow-type"), function(elem, index){ return $(elem).val(); }),
        to_hide = $(all_values).not([flow_type]).get();

    $.each(to_hide, function(index, hide) { return $('.' + hide).addClass('hidden'); });

    $('.' + flow_type).removeClass('hidden');
  }
};

// Bind events:
$(document).on('click', '.js-flow-type', RegistrationLinks.toggleNewForm);
