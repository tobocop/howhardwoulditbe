require 'spec_helper'

describe HomeController do
  describe '#index' do
    it 'is successful' do
      get :index
      response.should be_success
    end

    it 'assigns @user_registration_form' do
      mock_reg_form = mock("UserRegistationForm")
      controller.stub(user_registration_form: mock_reg_form)

      get :index

      assigns(:user_registration_form).should == mock_reg_form
    end
  end
end
