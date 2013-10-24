module Plink
  class WalletItemService
    def self.create_open_wallet_item(wallet_id, unlock_reason)
      Plink::OpenWalletItemRecord.create(
        wallet_id: wallet_id,
        wallet_slot_id: 1,
        wallet_slot_type_id: 1,
        unlock_reason: unlock_reason
      )
    end

    def get_for_wallet_id(wallet_id)
      wallet_record = Plink::WalletRecord.find(wallet_id)
      create_wallet_items(wallet_record.sorted_wallet_item_records)
    end

    private

    def create_wallet_items(wallet_item_records)
      wallet_item_records.map { |wallet_item_record| Plink::WalletItem.new(wallet_item_record) }
    end
  end
end
