var ReceiptPromotions = {
  addConversionUrl : function(e){
    current_field_count = $('.conversion_url').length
    field = $('.conversion_url').last().clone()
    id_regex = new RegExp('attributes([_\\]]\\[?)' + (current_field_count - 1),"g");
    replaced_field = field.html().replace(id_regex, 'attributes$1' + current_field_count)
    $('#conversion_urls').append('<tr class="conversion_url">' + replaced_field + '</tr>')
  }
};

// Bind events:
$(document).on('click', '#js-add-conversion-url', ReceiptPromotions.addConversionUrl);

