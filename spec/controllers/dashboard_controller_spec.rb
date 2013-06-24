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

    it 'assigns hero promotions ordered by order' do
      controller.stub(current_user: user)

      my_second_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 3)
      my_first_hero = create_hero_promotion(image_url: 'assets/my_image.jpg', title: 'for test', display_order: 1)

      get :show

      assigns(:hero_promotions).should == [my_first_hero, my_second_hero]
    end

    it 'assigns @current_tab' do
      controller.stub(current_user: user)

      get :show

      assigns(:current_tab).should == 'dashboard'
    end
  end
end