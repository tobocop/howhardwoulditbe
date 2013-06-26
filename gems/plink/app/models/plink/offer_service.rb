module Plink
  class OfferService
    def get_live_offers(virtual_currency_id)
      offer_records = OfferRecord.live_offers_for_currency(virtual_currency_id)
      create_offers(offer_records)
    end

    private

    def create_offers(offer_records)
      offer_records.map { |offer_record| Offer.new(offer_record) }
    end

  end
end
