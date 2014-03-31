var ReceiptSubmission = {
  addLineItem : function(e){
    current_field_count = $('.line-item').length
    field = $('.line-item').last().clone()
    id_regex = new RegExp('attributes([_\\]]\\[?)' + (current_field_count - 1),"g");
    replaced_field = field.html().replace(id_regex, 'attributes$1' + current_field_count)
    $('#line-items').append('<div class="line-item on_one_line">' + replaced_field + '</div>')
  },
};

// Bind events:
$(document).on('click', '#js-add-line-item', ReceiptSubmission.addLineItem);
