require 'spec_helper'

describe OffersController do
  describe 'GET index' do
    it 'does not require a user to be logged in' do
      controller.should_not_receive(:require_authentication)
      get :index
    end
  end
end
