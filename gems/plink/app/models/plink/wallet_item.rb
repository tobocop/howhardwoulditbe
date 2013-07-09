module Plink
  class WalletItem
    attr_accessor :wallet_item_record

    def initialize(wallet_item_record)
      self.wallet_item_record = wallet_item_record
    end

    def in_use?
      wallet_item_record.offers_virtual_currency_id.present?
    end

    def locked?
      wallet_item_record.locked?
    end

    def offer
      Plink::Offer.new(wallet_item_record.offer, wallet_item_record.offers_virtual_currency.virtual_currency_id)
    end
  end
end