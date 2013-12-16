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
      Plink::HeroPromotionRecord.should_receive(:create).
        with({'name' => 'captn planet', 'user_ids' => {}}).
        and_return(mock(Plink::HeroPromotionRecord, persisted?: true))

      post :create, {hero_promotion: {name: 'captn planet'}}

      response.should redirect_to '/hero_promotions'
    end

    it 'renders the new template when the hero promotion cannot be created' do
      Plink::HeroPromotionRecord.should_receive(:create).
        with({'name' => 'captn planet', 'user_ids' => {}}).
        and_return(mock(Plink::HeroPromotionRecord, persisted?: false))

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

      it 'parses the file and creates the record with a hash of user ids' do
        user_ids = {1 => true,2 => true,3 => true,4 => true}
        Plink::HeroPromotionRecord.should_receive(:create).
          with({'name' => 'captn planet', 'user_ids' => user_ids}).
          and_return(mock(Plink::HeroPromotionRecord, persisted?: false))

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
      fake_hero_promo.should_receive(:update_attributes).with({'name' => 'something else'}).and_return(true)

      put :update, {id: 6, hero_promotion: {name: 'something else'}}

      response.should redirect_to '/hero_promotions'
    end

    it 're-renders the edit form when the record cannot be updated' do
      fake_hero_promo = mock(:fake_hero_promo)
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return(fake_hero_promo)
      fake_hero_promo.should_receive(:update_attributes).with({'name' => 'something else'}).and_return(false)

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

      before do
        # The reader method is present in a real invocation, but missing from the
        # file object (http://stackoverflow.com/questions/7793510/mocking-file-uploads-in-rails-3-1-controller-tests)
        class << file
          attr_reader :tempfile
        end
      end

    it 'updates the record and redirects to the index when successful' do
      fake_hero_promo = mock(:fake_hero_promo)
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return(fake_hero_promo)
      user_ids = {1=>true, 2=>true, 3=>true, 4=>true}
      fake_hero_promo.should_receive(:update_attributes).with({'user_ids' => user_ids}).and_return(true)

      put :update_audience, {id: 6, hero_promotion: {user_ids: file}}

      response.should redirect_to '/hero_promotions'
    end

    it 're-renders the edit form when the record cannot be updated' do
      fake_hero_promo = mock(:fake_hero_promo)
      Plink::HeroPromotionRecord.should_receive(:find).with('6').and_return(fake_hero_promo)
      fake_hero_promo.should_receive(:update_attributes).and_return(false)

      put :update_audience, {id: 6, hero_promotion: {}}

      response.should render_template 'edit_audience'
    end
  end
end
