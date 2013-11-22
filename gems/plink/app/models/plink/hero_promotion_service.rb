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
          id: record.id,
          image_url: record.image_url,
          image_url_right: record.image_url_right,
          link: record.link,
          link_right: record.link_right,
          show_linked_users: record.show_linked_users,
          show_non_linked_users: record.show_non_linked_users,
          title: record.title,
          user_ids: record.user_ids
        }
      )
    end
  end
end
