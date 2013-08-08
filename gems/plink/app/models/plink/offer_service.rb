module Plink
  class OfferService
    def get_live_offers(virtual_currency_id)
      offer_records = OfferRecord.live_offers_for_currency(virtual_currency_id)
      create_offers(offer_records, virtual_currency_id)
    end

    def get_available_offers_for(wallet_id, virtual_currency_id)
      live_offers = OfferRecord.live_non_excluded_offers_for_currency(wallet_id, virtual_currency_id)
      selected_offers = OfferRecord.in_wallet(wallet_id)
      offer_records = live_offers - selected_offers
      create_offers(offer_records, virtual_currency_id)
    end

    private

    def create_offers(offer_records, virtual_currency_id)
      offer_records.map do |offer_record|
        Offer.new(
          {
            offer_record: offer_record,
            virtual_currency_id: virtual_currency_id,
            name: offer_record.advertiser.advertiser_name,
            image_url: offer_record.advertiser.logo_url,
            is_new: offer_record.is_new,
            is_promotion: offer_record.active_offers_virtual_currencies.first.try(:is_promotion),
            promotion_description: offer_record.active_offers_virtual_currencies.first.try(:promotion_description)
          }
        )
      end
    end
  end
end
