require 'spec_helper'

describe OffersController do
  describe 'GET index' do
    let(:offer) { new_offer }

    before(:each) do
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
      assigns(:offers).should == [offer]
    end

    it 'should assign hero promotions' do
      stub_collection = [stub]
      HeroPromotion.stub(:by_display_order) { stub_collection }
      get :index

      assigns(:hero_promotions).should == stub_collection
    end

  end
end
