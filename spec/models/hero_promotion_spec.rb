require 'spec_helper'

describe HeroPromotion do
  let(:valid_attributes) {
    {
        image_url: '/assets/foo.jpg',
        title: 'Yes',
        display_order: 1
    }
  }

  it 'can be valid' do
    HeroPromotion.new(valid_attributes).should be_valid
  end

  describe 'class methods' do
    it 'returns ordered promotions by display_order' do
      my_second_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 3)
      my_first_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 1)

      HeroPromotion.by_display_order.should == [my_first_hero, my_second_hero]
    end
  end
end
