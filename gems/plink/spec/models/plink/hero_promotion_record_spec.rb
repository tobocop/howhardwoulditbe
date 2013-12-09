require 'spec_helper'

describe Plink::HeroPromotionRecord do
  it{ should allow_mass_assignment_of(:display_order) }
  it{ should allow_mass_assignment_of(:image_url) }
  it{ should allow_mass_assignment_of(:image_url_right) }
  it{ should allow_mass_assignment_of(:is_active) }
  it{ should allow_mass_assignment_of(:link) }
  it{ should allow_mass_assignment_of(:link_right) }
  it{ should allow_mass_assignment_of(:name) }
  it{ should allow_mass_assignment_of(:same_tab_one) }
  it{ should allow_mass_assignment_of(:same_tab_two) }
  it{ should allow_mass_assignment_of(:show_linked_users) }
  it{ should allow_mass_assignment_of(:show_non_linked_users) }
  it{ should allow_mass_assignment_of(:title) }
  it{ should allow_mass_assignment_of(:user_ids) }

  let(:valid_attributes) {
    {
      display_order: 1,
      image_url: '/assets/foo.jpg',
      is_active: true,
      link: nil,
      name: 'namey',
      same_tab_one: true,
      same_tab_two: true,
      show_linked_users: true,
      show_non_linked_users: true,
      title: 'Yes'
    }
  }

  it 'can be valid' do
    Plink::HeroPromotionRecord.new(valid_attributes).should be_valid
  end

  it 'serializes user_ids from the database to a hash' do
    create_hero_promotion.user_ids.should be_a(Hash)
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

  it 'validates that an audience is present' do
    invalid_attrs = valid_attributes.merge(show_linked_users: nil, show_non_linked_users: nil, user_ids: {})
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should have(1).error_on(:show_linked_users)
    promotion.should have(1).error_on(:show_non_linked_users)
    promotion.should have(1).error_on(:user_ids)
  end

  it 'is valid if any audience is selected' do
    invalid_attrs = valid_attributes.merge(show_linked_users: true, show_non_linked_users: nil, user_ids: {})
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should_not have(1).error_on(:show_linked_users)
    promotion.should_not have(1).error_on(:show_non_linked_users)
    promotion.should_not have(1).error_on(:user_ids)
  end

  it 'does not allow for an audience by both user_ids and card link status' do
    invalid_attrs = valid_attributes.merge(show_linked_users: true, show_non_linked_users: nil, user_ids: {1 => true,2 => true,3 => true})
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should have(1).error_on(:show_linked_users)
    promotion.should have(1).error_on(:show_non_linked_users)
    promotion.should have(1).error_on(:user_ids)
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

  describe '#audience_by_user_id?' do
    let(:hero_promotion) { new_hero_promotion }

    it 'returns true is there are user_ids' do
      hero_promotion.user_ids = {1 => true}

      hero_promotion.audience_by_user_id?.should be_true
    end

    it 'returns false if there are not user_ids' do
      hero_promotion.user_ids = {}

      hero_promotion.audience_by_user_id?.should be_false
    end
  end
end
