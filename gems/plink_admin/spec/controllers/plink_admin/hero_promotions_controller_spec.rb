require 'spec_helper'

describe PlinkAdmin::HeroPromotionsController do
  let(:admin) { create_admin }

  describe 'POST create' do
    before do
      sign_in :admin, admin
    end

    it 'redirects to the listing view' do
      post :create, {hero_promotion: {}}
      response.should redirect_to '/hero_promotions'
    end

    it 'creates a hero promotion' do
      Plink::HeroPromotionRecord.should_receive(:create).with({'name' => 'captn planet'}).and_return(mock("HeroPromotion", persisted?: true))

      post :create, {hero_promotion: {name: 'captn planet'}}
    end

    it 'renders the new template when the hero promotion cannot be created' do
      Plink::HeroPromotionRecord.should_receive(:create).with({'name' => 'captn planet'}).and_return(mock("HeroPromotion", persisted?: false))

      post :create, {hero_promotion: {name: 'captn planet'}}

      response.should render_template 'new'
    end

  end
end
