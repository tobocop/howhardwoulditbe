module Plink
  class HeroPromotionService
    def active_promotions
      create_hero_promotions(HeroPromotionRecord.by_display_order.active)
    end

    private

    def create_hero_promotions(hero_promotion_records)
      hero_promotion_records.map {|record| create_hero_promotion(record) }
    end

    def create_hero_promotion(record)
      Plink::HeroPromotion.new(
        {
          title: record.title,
          image_url: record.image_url
        }
      )
    end
  end
end