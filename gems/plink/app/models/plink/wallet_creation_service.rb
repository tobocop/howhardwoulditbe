module Plink
  class WalletCreationService
    attr_accessor :user_id

    def self.default_creation_slot_count
      3
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
        Plink::WalletItemService.create_open_wallet_item(wallet.id, Plink::WalletRecord.join_unlock_reason)
      end
    end

    def create_locked_wallet_items(wallet, number_of_slots)
      number_of_slots.times do
        Plink::LockedWalletItemRecord.create!(
          wallet_id: wallet.id,
          wallet_slot_id: 1,
          wallet_slot_type_id: 1
        )
      end
    end
  end
end
