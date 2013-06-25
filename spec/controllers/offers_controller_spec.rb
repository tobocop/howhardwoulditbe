require 'spec_helper'

describe OffersController do
  describe 'GET index' do
    let(:offer) { new_offer }

    before(:each) do
      create_virtual_currency(subdomain: VirtualCurrency::DEFAULT_SUBDOMAIN)

      fake_offer_service = Plink::FakeOfferService.new({VirtualCurrency::DEFAULT_SUBDOMAIN => [offer]})

      controller.stub(:plink_offer_service) { fake_offer_service }
    end

    it 'does not require a user to be logged in' do
      controller.should_not_receive(:require_authentication)
      get :index
    end

    it 'looks up offers based on subdomain' do
      get :index

      assigns(:offers).should == [offer]
    end
  end
end
