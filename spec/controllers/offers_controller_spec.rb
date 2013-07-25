require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_offer_service'
require 'plink/test_helpers/fake_services/fake_hero_promotion_service'

describe OffersController do
  describe 'GET index' do
    let(:offer) { new_offer }

    before(:each) do
      controller.stub(:plink_hero_promotion_service).and_return(Plink::FakeHeroPromotionService.new(['promotion']))
      controller.stub(:current_virtual_currency) { stub(id: 123) }

      fake_offer_service = Plink::FakeOfferService.new({123 => [offer]})

      controller.stub(:plink_offer_service) { fake_offer_service }
    end

    it 'does not require a user to be logged in' do
      controller.should_not_receive(:require_authentication)
      get :index
    end

    it 'looks up offers based on current_virtual_currency_id' do
      get :index
      assigns(:offers).map(&:class).should == [OfferItemPresenter]
    end

    it 'should assign hero promotions' do
      get :index

      assigns(:hero_promotions).should == ['promotion']
    end

  end
end
