require 'spec_helper'

describe HomeController do
  describe '#index' do
    it 'is successful' do
      get :index
      response.should be_success
    end

  end

  describe 'GET plink_video' do
    it 'renders the template without a layout' do

      get :plink_video

      response.should render_template(layout: false)
    end
  end
end
