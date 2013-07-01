module Plink
  class WalletCreationService
    attr_accessor :user_id

    def self.default_creation_slot_count
      5
    end

    def self.default_wallet_slot_type_id
      1
    end

    def initialize(options = {})
      self.user_id = options.fetch(:user_id)
    end

    def create_for_user_id
      wallet = Plink::WalletRecord.create(user_id: self.user_id)
      1.upto(self.class.default_creation_slot_count) do |i|
        Plink::WalletItemRecord.create(wallet_id: wallet.id, wallet_slot_id: i, wallet_slot_type_id: self.class.default_wallet_slot_type_id)
      end
    end
  end
end