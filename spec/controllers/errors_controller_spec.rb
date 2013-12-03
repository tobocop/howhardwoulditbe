require 'spec_helper'

describe ErrorsController do
  describe 'GET general_error' do
    it 'returns an http status code of 500' do
      get :general_error
      response.status.should == 500
    end
  end

  describe 'GET not_found' do
    it 'returns an http status code of 404' do
      get :not_found
      response.status.should == 404
    end
  end
end
