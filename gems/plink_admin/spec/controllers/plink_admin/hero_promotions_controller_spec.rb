require 'spec_helper'

describe PlinkAdmin::HeroPromotionsController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    it 'sets up the hero promotions' do
      Plink::HeroPromotionRecord.stub_chain(:select, :order).and_return('active_relation_object')

      get :index

      assigns(:hero_promotions).should == 'active_relation_object'
    end
  end

  describe 'POST create' do
    it 'creates a hero promotion and redirects to the listing view' do
      Plink::HeroPromotionRecord.should_receive(:create_with_bulk_users).
        with(nil, {'name' => 'captn planet'}). #, 'user_ids_present' => false}).
        and_return(double(Plink::HeroPromotionRecord, persisted?: true))

      post :create, {hero_promotion: {name: 'captn planet'}}

      response.should redirect_to '/hero_promotions'
    end

    it 'renders the new template when the hero promotion cannot be created' do
      Plink::HeroPromotionRecord.stub(:create_with_bulk_users).
        and_return(double(Plink::HeroPromotionRecord, persisted?: false))

      post :create, {hero_promotion: {name: 'captn planet'}}

      response.should render_template 'new'
    end

    context 'with a file upload' do
      let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'), 'text/csv') }

      before do
        # The reader method is present in a real invocation, but missing from the
        # file object (http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests)
        class << file
          attr_reader :tempfile
        end
      end

      it 'calls create_with_bulk_users to handle file parsing' do
        Plink::HeroPromotionRecord.should_receive(:create_with_bulk_users).
          with(file, {'name' => 'captn planet', 'user_ids' => file}).
          and_return(double(persisted?: true))

        post :create, {hero_promotion: {name: 'captn planet', user_ids: file}}
      end
    end
  end

  describe 'GET edit' do
    it 'looks up the hero promotion by ID and assigns it' do
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return('promotion')

      get :edit, id: '6'

      assigns(:hero_promotion).should == 'promotion'
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      fake_hero_promo = mock(:fake_hero_promo)
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return(fake_hero_promo)
      fake_hero_promo.should_receive(:update_attributes).
        with({'name' => 'something else'}).and_return(true)

      put :update, {id: 6, hero_promotion: {name: 'something else'}}

      response.should redirect_to '/hero_promotions'
    end

    it 're-renders the edit form when the record cannot be updated' do
      fake_hero_promo = mock(:fake_hero_promo)
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return(fake_hero_promo)
      fake_hero_promo.should_receive(:update_attributes).
        with({'name' => 'something else'}).and_return(false)

      put :update, {id: 6, hero_promotion: {name: 'something else'}}

      response.should render_template 'edit'
    end
  end

  describe 'GET edit_audience' do
    it 'returns a hero promotion' do
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return('promotion')

      get :edit_audience, id: '6'

      assigns(:hero_promotion).should == 'promotion'
    end
  end

  describe 'PUT update_audience' do
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'), 'text/csv') }
    let(:hero_promotion) { mock(Plink::HeroPromotionRecord) }

    before do
      # The reader method is present in a real invocation, but missing from the
      # file object (http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests)
      class << file
        attr_reader :tempfile
      end

      Plink::HeroPromotionRecord.stub(:find).and_return(hero_promotion)
    end

    context 'for a successful update' do
      it 'updates the associated record' do
        hero_promotion.should_receive(:update_attributes_with_bulk_users).
          with(file, {'user_ids' => file}).and_return(true)

        put :update_audience, {id: 6, hero_promotion: {user_ids: file}}
      end

      it 'redirects the user to the index' do
        hero_promotion.stub(:update_attributes_with_bulk_users).and_return(true)

        put :update_audience, {id: 6, hero_promotion: {user_ids: file}}

        response.should redirect_to '/hero_promotions'
      end
    end

    it 're-renders the edit form when the record cannot be updated' do
      hero_promotion.stub(:update_attributes_with_bulk_users).and_return(false)

      put :update_audience, {id: 6, hero_promotion: {}}

      response.should render_template 'edit_audience'
    end
  end
end
