module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    alias_attribute :user_id, :userID

    attr_accessible :user_id

    has_many :wallet_item_records, class_name: 'Plink::WalletItemRecord', foreign_key: 'walletID'
    has_many :open_wallet_items, class_name: 'Plink::OpenWalletItemRecord', foreign_key: 'walletID'

    validates :user_id, presence: true
  end
end