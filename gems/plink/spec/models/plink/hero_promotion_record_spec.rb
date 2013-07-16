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

  it 'validates presence of name' do
    invalid_attributes = valid_attributes.merge(name: '')
    invalid_record = Plink::HeroPromotionRecord.new(invalid_attributes)
    invalid_record.should_not be_valid
    invalid_record.errors.full_messages.should == ["Name can't be blank"]
  end

  it 'requires a title and an image_url to not be blank to be valid' do
    promotion = Plink::HeroPromotionRecord.new(valid_attributes.merge(image_url: '', title:''))

    promotion.should have(1).error_on(:image_url)
    promotion.should have(1).error_on(:title)
  end

  describe 'class methods' do
    describe 'by_display_order' do
      it 'returns ordered promotions by display_order' do
        my_second_hero = create_hero_promotion(display_order: 3)
        my_first_hero = create_hero_promotion(display_order: 1)

        Plink::HeroPromotionRecord.by_display_order.should == [my_first_hero, my_second_hero]
      end
    end

    describe 'active' do
      it 'returns only active promos' do
        active_hero = create_hero_promotion(is_active: true)
        inactive_hero = create_hero_promotion(is_active: false)

        Plink::HeroPromotionRecord.active.should == [active_hero]
      end
    end
  end
end
