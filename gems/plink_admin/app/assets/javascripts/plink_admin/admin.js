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
  }
};

// Bind events:
$(document).on('click', '.js-user-edit-open-wallet-item-slot', Admin.unlockWalletItem);
