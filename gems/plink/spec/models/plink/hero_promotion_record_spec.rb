require 'spec_helper'

describe Plink::HeroPromotionRecord do
  it { should allow_mass_assignment_of(:display_order) }
  it { should allow_mass_assignment_of(:image_url_one) }
  it { should allow_mass_assignment_of(:image_url_two) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:link_one) }
  it { should allow_mass_assignment_of(:link_two) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:same_tab_one) }
  it { should allow_mass_assignment_of(:same_tab_two) }
  it { should allow_mass_assignment_of(:show_linked_users) }
  it { should allow_mass_assignment_of(:show_non_linked_users) }
  it { should allow_mass_assignment_of(:title) }
  it { should allow_mass_assignment_of(:user_ids_present) }

  let(:user) { create_user }
  let(:valid_attributes) {
    {
      display_order: 1,
      image_url_one: '/assets/foo.jpg',
      is_active: true,
      link_one: nil,
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

  it 'validates presence of name' do
    invalid_attributes = valid_attributes.merge(name: '')
    invalid_record = Plink::HeroPromotionRecord.new(invalid_attributes)
    invalid_record.should_not be_valid
    invalid_record.errors.full_messages.should == ["Name can't be blank"]
  end

  it 'requires a title and image_url_one to not be blank to be valid' do
    promotion = Plink::HeroPromotionRecord.new(valid_attributes.merge(image_url_one: '', title:''))

    promotion.should have(1).error_on(:image_url_one)
    promotion.should have(1).error_on(:title)
  end

  it 'validates that an audience is present' do
    invalid_attrs = valid_attributes.merge(show_linked_users: nil, show_non_linked_users: nil, user_ids_present: false)
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should have(1).error_on(:show_linked_users)
    promotion.should have(1).error_on(:show_non_linked_users)
    promotion.should have(1).error_on(:user_ids_present)
  end

  it 'is valid if any audience is selected' do
    invalid_attrs = valid_attributes.merge(show_linked_users: true, show_non_linked_users: nil, user_ids_present: false)
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should_not have(1).error_on(:show_linked_users)
    promotion.should_not have(1).error_on(:show_non_linked_users)
    promotion.should_not have(1).error_on(:user_ids_present)
  end

  it 'does not allow for an audience by both user_ids and card link status' do
    invalid_attrs = valid_attributes.merge(show_linked_users: true, show_non_linked_users: nil, user_ids_present: true)
    promotion = Plink::HeroPromotionRecord.new(invalid_attrs)

    promotion.should have(1).error_on(:show_linked_users)
    promotion.should have(1).error_on(:show_non_linked_users)
    promotion.should have(1).error_on(:user_ids_present)
  end

  describe '.by_display_order' do
    it 'returns ordered promotions by display_order' do
      my_second_hero = create_hero_promotion(display_order: 3)
      my_first_hero = create_hero_promotion(display_order: 1)

      Plink::HeroPromotionRecord.by_display_order.should == [my_first_hero, my_second_hero]
    end
  end

  describe '.active' do
    it 'returns only active promos' do
      active_hero = create_hero_promotion(is_active: true)
      inactive_hero = create_hero_promotion(is_active: false)

      Plink::HeroPromotionRecord.active.should == [active_hero]
    end
  end

  describe '.by_user_id_and_linked' do
    it 'returns promotions the specific user should see' do
      promotion_for_user = create_hero_promotion
      create_hero_promotion_user(user_id: 6, hero_promotion_id: promotion_for_user.id)
      other_promotion = create_hero_promotion(name: 'stuff', show_linked_users: true)
      second_other_promotion = create_hero_promotion(name: 'stuff 2', show_linked_users: false)

      promotions = Plink::HeroPromotionRecord.by_user_id_and_linked(6, true)
      promotions.should include promotion_for_user
      promotions.should include other_promotion
      promotions.should_not include second_other_promotion
    end

    it 'does not return a promotion if the user should not see it' do
      promotion_for_user = create_hero_promotion(show_linked_users: nil, show_non_linked_users: nil, user_ids_present: true)
      create_hero_promotion_user(user_id: 6, hero_promotion_id: promotion_for_user.id)

      Plink::HeroPromotionRecord.by_user_id_and_linked(7, true).should be_empty
    end

    it 'does not return a promotion if only linked promotions exist and the user is unlinked' do
      promotion_for_user = create_hero_promotion(show_linked_users: true, show_non_linked_users: nil)

      Plink::HeroPromotionRecord.by_user_id_and_linked(7, false).should be_empty
    end
  end

  describe '.create_with_bulk_users' do
    let(:user_ids_file) { double(tempfile: 'stuff') }

    it 'calls Plink::HeroPromotionRecord.create' do
      Plink::HeroPromotionRecord.should_receive(:create).
        with({foo: 'bar', user_ids_present: false}).and_return(double(persisted?: true))

      Plink::HeroPromotionRecord.create_with_bulk_users({foo: 'bar'}, nil)
    end

    it 'saves the uploaded file in to tmp/' do
      Plink::HeroPromotionRecord.stub(:create).and_return(double(persisted?: true, id: 1))
      hero_promotion_user_record = double(Plink::HeroPromotionUserRecord, bulk_insert: true)
      Plink::HeroPromotionUserRecord.stub(:delay).and_return(hero_promotion_user_record)

      FileUtils.should_receive(:mv).and_return(true)

      Plink::HeroPromotionRecord.create_with_bulk_users({foo: 'bar'}, user_ids_file)
    end

    it 'calls a delayed job to bulk insert the records' do
      Plink::HeroPromotionRecord.stub(:create).and_return(double(persisted?: true, id: 1))
      hero_promotion_user_record = double(Plink::HeroPromotionUserRecord, bulk_insert: true)
      FileUtils.stub(:mv).and_return(true)

      Plink::HeroPromotionUserRecord.should_receive(:delay).and_return(hero_promotion_user_record)

      Plink::HeroPromotionRecord.create_with_bulk_users({foo: 'bar'}, user_ids_file)
    end
  end

  describe '#update_attributes_with_bulk_users' do
    let(:user_ids_file) { double(tempfile: 'stuff') }
    let(:hero_promotion) { create_hero_promotion }
    let(:params) { {name: 'best hero promotion evar'} }

    it 'calls update_attributes' do
      hero_promotion.should_receive(:update_attributes).with(params.merge!(user_ids_present: true))


      hero_promotion.update_attributes_with_bulk_users(params, user_ids_file)
    end

    it 'returns the response of update_attributes' do
      hero_promotion.stub(:update_attributes).and_return(false)


      hero_promotion.update_attributes_with_bulk_users(params, user_ids_file).should be_false
    end

    context 'with a user_ids file' do
      before { hero_promotion.stub(:update_attributes).and_return(true) }

      it 'moves the file into the /tmp directory' do
        Plink::HeroPromotionUserRecord.stub(:delay).and_return(double(bulk_insert: true))

        FileUtils.should_receive(:mv).
          with('stuff', /tmp\/uploaded_files\/hero_promotion_users_.*\.csv/)

        hero_promotion.update_attributes_with_bulk_users(params, user_ids_file)
      end

      it 'creates a delayed job to handle the bulk insert' do
        FileUtils.stub(:mv).and_return(nil)

        Plink::HeroPromotionUserRecord.should_receive(:delay).
          and_return(double(bulk_insert: true))

        hero_promotion.update_attributes_with_bulk_users(params, user_ids_file)
      end
    end

  end

  describe '#user_count' do
    it 'calls the model in a non-blocking way' do
      hero_promotion = create_hero_promotion

      Plink::HeroPromotionUserRecord.should_receive(:joins).with('WITH (NOLOCK)').
        and_return(double(where: []))

      hero_promotion.user_count
    end

    it 'returns a count of the users associatied with the hero_promotion' do
      hero_promotion = create_hero_promotion

      Plink::HeroPromotionUserRecord.stub(:joins).
        and_return(double(where: [double, double, double]))

      hero_promotion.user_count.should == 3
    end
  end
end
