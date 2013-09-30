require 'spec_helper'

describe SurveyController do
  describe 'GET complete' do
    it 'is successful' do
      get :complete
      response.should be_success
    end
  end
end
