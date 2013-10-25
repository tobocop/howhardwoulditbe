module PlinkAdmin
  module UsersHelper
    def open_slot_link(unlock_reason, wallet_item_record_id)
      options = {
        class: 'js-user-edit-open-wallet-item-slot',
        data: {
          unlock_reason: unlock_reason,
          wallet_item_record_id: wallet_item_record_id
        }
      }

      link_to unlock_reason.titleize, nil, options
    end

    def give_open_slot_link(unlock_reason, wallet_id)
      options = {
        class: 'js-user-edit-give-open-wallet-item',
        data: {
          unlock_reason: unlock_reason,
          wallet_record_id: wallet_id
        }
      }

      link_to unlock_reason.titleize, nil, options
    end
  end
end
