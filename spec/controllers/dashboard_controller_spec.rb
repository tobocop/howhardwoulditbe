require 'spec_helper'

describe DashboardController do
  let(:user) { new_user }

  describe 'GET show' do
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

      stub_collection = [stub]
      HeroPromotion.stub(:by_display_order) { stub_collection }
      get :show

      assigns(:hero_promotions).should == stub_collection
    end

    it 'assigns @current_tab' do
      controller.stub(:user_logged_in?) { true }

      get :show

      assigns(:current_tab).should == 'dashboard'
    end
  end
end