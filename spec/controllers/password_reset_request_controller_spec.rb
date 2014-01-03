require 'spec_helper'

describe PasswordResetRequestController do
  describe 'POST create' do
    it 'redirect to the home page and set a flash message if email is found' do
      PasswordResetRequestForm.stub(:new).with({'email' => 'mail@example.com'}).and_return(double(:fake_password_reset, save: true))
      post :create, password_reset: {email: 'mail@example.com'}

      flash.notice.should == 'To reset your password, please follow the instructions sent to your email address.'
      response.should redirect_to root_path
    end

    it 're-renders the form if the reset cannot be sent' do
      PasswordResetRequestForm.stub(:new).with({'email' => 'mail@example.com'}).and_return(double(:fake_password_reset, save: false))

      post :create, password_reset: {email: 'mail@example.com'}

      response.should render_template 'new'
    end
  end
end
