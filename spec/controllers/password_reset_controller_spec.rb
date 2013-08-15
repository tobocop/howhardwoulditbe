require 'spec_helper'

describe PasswordResetController do

  describe 'GET new' do
    it 'should assign @contact_form' do
      get :new

      assigns(:password_reset).should be_present
    end
  end

  describe 'POST create' do
    let(:params) { {'token' => 'token', 'new_password' => 'pazzword', 'new_password_confirmation' => 'pazzword'} }

    context 'when password is successfully changed' do
      let(:mock_password_reset_form) { mock(:password_reset_form, save: true) }

      before do
        PasswordResetForm.stub(:new).and_return(mock_password_reset_form)
      end

      it 'redirects to the home page with a flash notice' do
        PasswordResetForm.should_receive(:new).with(params).and_return(mock_password_reset_form)

        post :create, password_reset: params

        response.should redirect_to root_path
        flash.notice.should == "Your password has been successfully updated. Please sign in."
      end
    end

    context 'when the password cant be changed' do
      let(:mock_password_reset_form) { mock(:password_reset_form, save: false) }

      before do
        PasswordResetForm.stub(:new).and_return(mock_password_reset_form)
      end

      it 're-renders the new template' do
        post :create, password_reset: params

        response.should render_template 'new'
      end
    end
  end
end
