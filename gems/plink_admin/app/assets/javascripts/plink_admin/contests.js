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
  }
};

// Bind events:
$(document).on('keyup', '#number_of_entries', Contests.updateEntries);
$(document).on('submit', '#js-contest-entry-form', Contests.entryConfirmation);
$(document).on('click', '.js-toggle-contest-winners-table', Contests.toggleContestWinnersTable);
