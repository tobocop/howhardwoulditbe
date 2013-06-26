module Plink
  class OfferService
    def get_offers(virtual_currency_id)
      offer_records = OfferRecord.joins(:offers_virtual_currencies).
          where("#{OffersVirtualCurrencyRecord.table_name}.virtualCurrencyID = ?", virtual_currency_id)
      offer_records.map do |offer_record|
        Offer.new(offer_record)
      end
    end

  end
end
