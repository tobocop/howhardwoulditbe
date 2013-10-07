require 'spec_helper'

describe HomeController do
  describe '#index' do
    before :each do
      controller.stub(:current_virtual_currency) { stub(id: 1) }
    end

    it 'is successful' do
      controller.stub(:user_logged_in?) { false }
      get :index
      response.should be_success
    end

    it 'redirects members who are signed in to the wallet page' do
      controller.stub(:user_logged_in?) { true }
      get :index
      response.should be_redirect
    end

    it 'should assign the steelhouse additional info string' do
      controller.stub(:user_logged_in?) { false }
      TrackingObject.any_instance.should_receive(:steelhouse_additional_info).and_call_original
      get :index
      assigns(:steelhouse_additional_info).should be_present
    end
  end

  describe 'GET plink_video' do
    it 'renders the template without a layout' do

      get :plink_video

      response.should render_template(layout: false)
    end
  end
end
