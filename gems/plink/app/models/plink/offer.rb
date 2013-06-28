module Plink
  class Offer

    attr_reader :id, :tiers, :detail_text, :name, :image_url

    def initialize(offer_record, virtual_currency_id)
      @id = offer_record.id
      @tiers = offer_tiers(offer_record, virtual_currency_id)
      @detail_text = detail_text_for_offer(offer_record)
      @name = offer_record.advertiser.advertiser_name
      @image_url = offer_record.advertiser.logo_url
    end

    def max_dollar_award_amount
      return if tiers.empty?
      tiers.max_by(&:dollar_award_amount).dollar_award_amount
    end

    def tiers_by_minimum_purchase_amount
      tiers.sort { |a, b| a.minimum_purchase_amount <=> b.minimum_purchase_amount }
    end

    def minimum_purchase_amount_tier
      tiers.min_by(&:minimum_purchase_amount)
    end

    private

    def offer_tiers(offer_record, virtual_currency_id)
      offer_record.live_tiers.for_virtual_currency(virtual_currency_id).map { |tier| Plink::Tier.new(tier) }
    end

    def detail_text_for_offer(offer_record)
      offer_record.offers_virtual_currencies.first.detail_text || offer_record.detail_text
    end
  end
end
