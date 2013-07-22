require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_hero_promotion_service'

describe DashboardController, pending: true do
  let(:user) { new_user }

  describe 'GET show' do

    before do
      controller.stub(:plink_hero_promotion_service).and_return(Plink::FakeHeroPromotionService.new(['promotion']))
    end

    it 'renders the dashboard if a current user exists' do
      controller.stub(:require_authentication) { true }
      get :show
      response.should be_success
    end

    it 'redirects to the home page if the user is not logged in' do
      get :show
      response.should be_redirect
    end

    it 'should assign hero promotions' do
      controller.stub(:user_logged_in?) { true }

      get :show

      assigns(:hero_promotions).should == ['promotion']
    end

    it 'assigns @current_tab' do
      controller.stub(:user_logged_in?) { true }

      get :show

      assigns(:current_tab).should == 'dashboard'
    end
  end
end
