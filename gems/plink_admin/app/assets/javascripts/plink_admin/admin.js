var Admin = {
  unlockWalletItem : function(e) {
    var $this = $(this),
        unlock_reason = $(this).data().unlockReason,
        wallet_item_record_id = $(this).data().walletItemRecordId;

    $.ajax({
      url: '/plink_admin/wallet_items/' + wallet_item_record_id + '/unlock_wallet_item_with_reason',
      method: "POST",
      data: { unlock_reason : unlock_reason, id : wallet_item_record_id },
      success: function(resp) {
        $this.parent().html(resp.message);
      },
      error: function(xhr) {
        $this.parent().html($.parseJSON(xhr.responseText).message);
      }
    })

    return false;
  },

  upadateEntries : function(e) {
    var $this = $(this);

    $("#js-total-entries").html(Admin.computeEntries($this));

    return false;
  },

  computeEntries : function(elem) {
    var multiplier = $("#js-multiplier").data().multiplier,
        entered_value = elem.val(),
        total = multiplier * entered_value;

    return total;
  },

  contestEntryConfirmation : function (e) {
    var entries = Admin.computeEntries($("#number_of_entries")),
        confirm_message = 'You are about to award ' + entries + ' entries. Are you sure?';

    if ( entries <= 100 || entries > 100 && confirm(confirm_message)) {
      return true;
    } else {
      return false;
    }
  }
};

// Bind events:
$(document).on('click', '.js-user-edit-open-wallet-item-slot', Admin.unlockWalletItem);
$(document).on('keyup', '#number_of_entries', Admin.upadateEntries);
$(document).on('submit', '#js-contest-entry-form', Admin.contestEntryConfirmation);
