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

    def give_open_slot_link(unlock_reason, wallet_id)
      klass = 'js-user-edit-give-open-wallet-item'
      options = {
        class: klass,
        data: {
          unlock_reason: unlock_reason,
          wallet_record_id: wallet_id
        }
      }
      link_to unlock_reason.titleize, nil, options
    end
  end
end
