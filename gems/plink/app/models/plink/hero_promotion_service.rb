module Plink
  class HeroPromotionService
    def active_promotions
      create_hero_promotions(HeroPromotionRecord.by_display_order.active)
    end

    def active_for_user(user_id, linked_card)
      promotions = HeroPromotionRecord.by_display_order.active.
        by_user_id_and_linked(user_id, linked_card)

      create_hero_promotions(promotions)
    end

  private

    def create_hero_promotions(hero_promotion_records)
      hero_promotion_records.map {|record| create_hero_promotion(record) }
    end

    def create_hero_promotion(record)
      Plink::HeroPromotion.new(
        {
          id: record.id,
          image_url_one: record.image_url_one,
          image_url_two: record.image_url_two,
          link_one: record.link_one,
          link_two: record.link_two,
          same_tab_one: record.same_tab_one,
          same_tab_two: record.same_tab_two,
          show_linked_users: record.show_linked_users,
          show_non_linked_users: record.show_non_linked_users,
          title: record.title
        }
      )
    end
  end
end
