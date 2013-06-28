module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    alias_attribute :user_id, :userID

    attr_accessible :user_id

    validates :user_id, presence: true


  end
end