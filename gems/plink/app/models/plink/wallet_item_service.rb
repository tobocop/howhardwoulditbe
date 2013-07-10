module Plink
  class WalletItemService
    def get_for_wallet_id(wallet_id)
      wallet = Plink::WalletRecord.find(wallet_id)
      create_wallet_items(wallet.wallet_items)
    end

    private

    def create_wallet_items(wallet_item_records)
      wallet_item_records.map { |wallet_item_record| Plink::WalletItem.new(wallet_item_record) }
    end
  end
end