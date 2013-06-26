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
        my_second_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 3)
        my_first_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 1)

        get :show

        assigns(:hero_promotions).should == [my_first_hero, my_second_hero]
      end

      it 'should assign current tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end
    end
  end
end