require 'spec_helper'

describe Plink::HeroPromotionService do
  describe 'active_promotions' do
    it 'returns a set of ordered, active HeroPromotions' do
      second_active_promo = create_hero_promotion(title: 'second', is_active: true, display_order: 2)
      first_active_promo = create_hero_promotion(title: 'first', is_active: true, display_order: 1)
      inactive_promo = create_hero_promotion(is_active: false)

      subject.active_promotions.map(&:title).should == ['first', 'second']
      subject.active_promotions.map(&:class).should == [Plink::HeroPromotion, Plink::HeroPromotion]
    end
  end
end
