require 'spec_helper'

describe Plink::HeroPromotionService do
  subject(:hero_promotion_service) { Plink::HeroPromotionService.new }

  describe '#active_promotions' do
    it 'returns an ordered set of active HeroPromotions' do
      first_active_promo = create_hero_promotion(title: 'first', is_active: true, display_order: 1)
      second_active_promo = create_hero_promotion(title: 'second', is_active: true, display_order: 2)
      inactive_promo = create_hero_promotion(is_active: false)

      hero_promotion_service.active_promotions.map(&:title).should == ['first', 'second']
      hero_promotion_service.active_promotions.map(&:class).should == [Plink::HeroPromotion, Plink::HeroPromotion]
    end
  end

  describe '#active_for_user' do
    it 'returns an ordered set of active HeroPromotions' do
      first_active_promo = create_hero_promotion(title: 'first', is_active: true, display_order: 1, show_non_linked_users: true)
      second_active_promo = create_hero_promotion(title: 'second', is_active: true, display_order: 2, show_non_linked_users: true)
      inactive_promo = create_hero_promotion(is_active: false)
      unlinked_promo = create_hero_promotion(title: 'second', show_non_linked_users: nil, show_linked_users: nil, user_ids_present: true, is_active: true, display_order: 6)
      create_hero_promotion_user(user_id: 50, hero_promotion_id: unlinked_promo.id)

      promotions = hero_promotion_service.active_for_user(50, false)
      promotions[0].id.should == first_active_promo.id
      promotions[1].id.should == second_active_promo.id
      promotions[2].id.should == unlinked_promo.id
    end
  end
end
