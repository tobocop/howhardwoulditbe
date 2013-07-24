module Plink
  class WalletItem
    attr_accessor :wallet_item_record

    def initialize(wallet_item_record)
      self.wallet_item_record = wallet_item_record
    end

    delegate :populated?, :locked?, :open?, to: :wallet_item_record

    def offer
      offer_record = wallet_item_record.offer

      Plink::Offer.new(
        offer_record: offer_record,
        virtual_currency_id: wallet_item_record.offers_virtual_currency.virtual_currency_id,
        name: offer_record.advertiser.advertiser_name,
        image_url: offer_record.advertiser.logo_url,
        is_new: offer_record.is_new,
        is_promotion: offer_record.active_offers_virtual_currencies.first.try(:is_promotion)
      )
    end
  end
end