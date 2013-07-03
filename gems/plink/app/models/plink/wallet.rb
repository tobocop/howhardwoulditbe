module Plink
  class Wallet
    attr_accessor :wallet_record

    def initialize(wallet_record)
      self.wallet_record = wallet_record
    end

    def wallet_item_for_offer(offers_virtual_currency)
      wallet_record.wallet_items.detect { |item| item.offers_virtual_currency_id == offers_virtual_currency.id }
    end
  end
end
