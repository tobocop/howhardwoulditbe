require 'spec_helper'

describe PlinkAnalytics::MarketShareController do
  describe 'GET show' do
    it 'is successful' do
      get :show

      response.should be_successful
    end
  end
end
