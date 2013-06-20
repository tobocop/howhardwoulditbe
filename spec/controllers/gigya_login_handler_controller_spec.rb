require 'spec_helper'

describe GigyaLoginHandlerController do
  describe '#create' do
    let(:user_stub) { stub }
    let(:gigya_connection) { stub }
    before do
      controller.stub(:gigya_connection) { gigya_connection }
      GigyaSocialLoginService.stub(:new).with({"valid_params" => true, 'gigya_connection' => gigya_connection}) { gigya_social_login_service_stub }
    end

    context 'when the request is valid and user is found' do
      let(:gigya_social_login_service_stub) { stub(user: user_stub, successful?: true) }

      it 'signs the user in' do
        controller.should_receive(:sign_in_user).with(user_stub)
        get :create, {valid_params: true}
      end

      it 'redirects the user' do
        controller.stub(:sign_in_user)
        get :create, {valid_params: true}
        response.should be_redirect
      end
    end
  end
end