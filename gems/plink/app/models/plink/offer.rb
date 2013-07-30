module Plink
  class Offer

    attr_reader :id, :tiers, :detail_text, :name, :image_url, :is_new, :is_promotion, :promotion_description

    def initialize(attributes={})
      offer_record = attributes.fetch(:offer_record)
      virtual_currency_id = attributes.fetch(:virtual_currency_id)

      @id = offer_record.id
      @tiers = offer_tiers(offer_record, virtual_currency_id)
      @detail_text = detail_text_for_offer(offer_record)
      @name = attributes[:name]
      @image_url = attributes[:image_url]
      @is_new = attributes.fetch(:is_new, false)
      @is_promotion = attributes.fetch(:is_promotion, false)
      @promotion_description = attributes.fetch(:promotion_description, nil)
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
