module Plink
  class Offer

    attr_reader :detail_text, :end_date, :image_url, :id, :is_new, :is_promotion, :name, :promotion_description, :tiers

    def initialize(attributes={})
      offer_record = attributes.fetch(:offer_record)
      virtual_currency_id = attributes.fetch(:virtual_currency_id)

      @detail_text = detail_text_for_offer(offer_record)
      @end_date = offer_record.end_date.to_date
      @image_url = attributes[:image_url]
      @id = offer_record.id
      @is_new = attributes.fetch(:is_new, false)
      @is_promotion = attributes.fetch(:is_promotion, false)
      @name = attributes[:name]
      @promotion_description = attributes.fetch(:promotion_description, nil)
      @tiers = offer_tiers(offer_record, virtual_currency_id)
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
