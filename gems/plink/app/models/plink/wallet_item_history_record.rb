module Plink
  class WalletItemHistoryRecord < ActiveRecord::Base
    self.table_name = 'walletItemsHistory'

    include LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID
    alias_attribute :users_award_period_id, :usersAwardPeriodID
    alias_attribute :wallet_item_id, :walletItemID
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id, :users_award_period_id, :wallet_item_id, :offers_virtual_currency_id

    def self.clone_from_wallet_item(wallet_item)
      attrs = wallet_item.attributes

      create do |record|
        record.wallet_id = attrs['walletID']
        record.wallet_slot_id = attrs['walletSlotID']
        record.wallet_slot_type_id = attrs['walletSlotTypeID']
        record.wallet_item_id = attrs['walletItemID']
        record.users_award_period_id = attrs['usersAwardPeriodID']
        record.offers_virtual_currency_id = attrs['offersVirtualCurrencyID']
      end
    end
  end
end