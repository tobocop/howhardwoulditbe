require 'spec_helper'

describe Plink::HeroPromotionRecord do
  let(:valid_attributes) {
    {
        image_url: '/assets/foo.jpg',
        title: 'Yes',
        display_order: 1,
        name: 'namey',
        is_active: true
    }
  }

  it 'can be valid' do
    Plink::HeroPromotionRecord.new(valid_attributes).should be_valid
  end

  it 'requires a title and an image_url to not be blank to be valid' do
    promotion = Plink::HeroPromotionRecord.new(valid_attributes.merge(image_url: '', title:''))

    promotion.should have(1).error_on(:image_url)
    promotion.should have(1).error_on(:title)
  end

  describe 'class methods' do
    it 'returns ordered promotions by display_order' do
      my_second_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 3)
      my_first_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 1)

      Plink::HeroPromotionRecord.by_display_order.should == [my_first_hero, my_second_hero]
    end
  end
end
