module PlinkAdmin
  module HeroPromotionsHelper
    def determine_audience(hero_promotion)
      if hero_promotion.audience_by_user_id?
        'List of Users'
      elsif hero_promotion.show_linked_users &&  hero_promotion.show_non_linked_users
        'All'
      elsif hero_promotion.show_linked_users
        'Linked Users'
      elsif hero_promotion.show_non_linked_users
        'Non-Linked Users'
      end
    end
  end
end
