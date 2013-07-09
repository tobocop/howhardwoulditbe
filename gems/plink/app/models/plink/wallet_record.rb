module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    alias_attribute :user_id, :userID

    attr_accessible :user_id

    has_many :wallet_items, class_name: 'Plink::WalletItemRecord', foreign_key: 'walletID'
    has_many :empty_wallet_items, class_name: 'Plink::EmptyWalletItemRecord', foreign_key: 'walletID'

    validates :user_id, presence: true
  end
end