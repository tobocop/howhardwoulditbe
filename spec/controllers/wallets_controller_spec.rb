require 'spec_helper'

describe WalletsController do

  describe '#show' do
    it 'redirects to the home page if the user is not logged in' do
      get :show
      response.should be_redirect
    end

    context 'logged in' do
      before do
        controller.stub(:require_authentication) { true }
      end

      it 'should assign hero promotions' do
        stub_collection = [stub]
        HeroPromotion.stub(:by_display_order) { stub_collection }
        get :show

        assigns(:hero_promotions).should == stub_collection
      end

      it 'should assign current tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end
    end
  end
end