var Contests = {
  updateEntries : function(e) {
    var $this = $(this);

    $("#js-total-entries").html(Contests.computeEntries($this));

    return false;
  },

  computeEntries : function(elem) {
    var multiplier = $("#js-multiplier").data().multiplier,
        entered_value = elem.val(),
        total = multiplier * entered_value;

    return total;
  },

  entryConfirmation : function (e) {
    var entries = Contests.computeEntries($("#number_of_entries")),
        confirm_message = 'You are about to award ' + entries + ' entries. Are you sure?';

    if ( entries <= 100 || (entries > 100 && confirm(confirm_message))) {
      return true;
    } else {
      return false;
    }
  },

  toggleContestWinnersTable : function(e) {
    $(this).next('.contest-winners-toggleable-table').toggle();

    var show_or_hide = $(this).text() === "Show" ? "Hide" : "Show";
    $(this).text(show_or_hide);

    return false;
  },

  addPrizeLevel : function(e){
    current_field_count = $('.prize_level').length
    field = $(
      '<div class="prize_level on_one_line">' +
        '<label for="contest_contest_prize_levels_attributes_' + current_field_count + '_award_count">Award count</label>' +
        '<input id="contest_contest_prize_levels_attributes_' + current_field_count + '_award_count" name="contest[contest_prize_levels_attributes][' + current_field_count + '][award_count]" size="30" type="text" value="">' +
        '<label for="contest_contest_prize_levels_attributes_' + current_field_count + '_dollar_amount">Dollar amount</label>' +
        '<input id="contest_contest_prize_levels_attributes_' + current_field_count + '_dollar_amount" name="contest[contest_prize_levels_attributes][' + current_field_count + '][dollar_amount]" size="30" type="text" value="">' +
        '<br clear="left">' +
      '</div>'
    )
    $('#prize_levels').append(field)
  },

  removePrizeLevel : function(e){
    $(this).parent().remove()
  }
};

// Bind events:
$(document).on('keyup', '#number_of_entries', Contests.updateEntries);
$(document).on('submit', '#js-contest-entry-form', Contests.entryConfirmation);
$(document).on('click', '.js-toggle-contest-winners-table', Contests.toggleContestWinnersTable);
$(document).on('click', '#js-add-prize-level', Contests.addPrizeLevel);

