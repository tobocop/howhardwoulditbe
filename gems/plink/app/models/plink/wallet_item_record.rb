module Plink
  class WalletItemRecord < ActiveRecord::Base

    self.table_name = 'walletItems'

    include Plink::LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id

    validates :wallet_id, :wallet_slot_id, :wallet_slot_type_id, presence: true
  end
end