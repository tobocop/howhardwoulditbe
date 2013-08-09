module PlinkAdmin
  module UsersHelper

    def open_slot_link(unlock_reason, wallet_item_record_id)
      klass = 'js-user-edit-open-wallet-item-slot'
      options = {
        class: klass,
        data: {
          unlock_reason: unlock_reason,
          wallet_item_record_id: wallet_item_record_id
        }
      }

      link_to unlock_reason.titleize, nil, options
    end

  end
end
