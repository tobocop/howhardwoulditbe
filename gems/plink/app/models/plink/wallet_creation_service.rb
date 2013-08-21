module Plink
  class WalletCreationService
    attr_accessor :user_id

    def self.default_creation_slot_count
      3
    end

    def self.default_wallet_slot_type_id
      1
    end

    def initialize(options = {})
      self.user_id = options.fetch(:user_id)
    end

    def create_for_user_id(args = {})
      wallet = create_wallet
      create_open_wallet_items(wallet)
      create_locked_wallet_items(wallet, args.fetch(:number_of_locked_slots))
    end

    private

    def create_wallet
      Plink::WalletRecord.create(user_id: self.user_id)
    end

    def create_open_wallet_items(wallet)
      1.upto(self.class.default_creation_slot_count) do |i|
        wallet_item_params = {
          wallet_id: wallet.id,
          wallet_slot_id: i,
          wallet_slot_type_id: self.class.default_wallet_slot_type_id,
          unlock_reason: Plink::WalletRecord.join_unlock_reason
        }
        Plink::OpenWalletItemRecord.create(wallet_item_params)
      end
    end

    def create_locked_wallet_items(wallet, number_of_slots)
      number_of_slots.times do
        Plink::LockedWalletItemRecord.create!(
          wallet_id: wallet.id,
          wallet_slot_id: 1,
          wallet_slot_type_id: self.class.default_wallet_slot_type_id
        )
      end
    end
  end
end
