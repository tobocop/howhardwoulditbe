require 'spec_helper'

describe GigyaLoginHandlerController do
  describe '#create' do
    let(:gigya_connection) { stub(:gigya_connection) }
    let(:user) { mock('user') }

    before do
      controller.stub(:gigya_connection) { gigya_connection }
    end

    context 'when the request is valid and user is found' do
      let(:successful_response) { mock('success response', success?: true, new_user?: false ) }
      let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: successful_response) }

      before do
        GigyaSocialLoginService.stub(:new).with({"valid_params" => true, 'gigya_connection' => gigya_connection}) { gigya_social_login_service_stub }
      end

      it 'signs the user in' do
        controller.should_receive(:sign_in_user).with(user)

        get :create, {valid_params: true}

        response.should redirect_to dashboard_path
      end
    end

    context 'when the request is valid and user is a new_user' do
      let(:successful_response) { mock('success response', success?: true, new_user?: true) }
      let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: mock('user', id: 87, password_hash: 'asd'), sign_in_user: successful_response) }

      before do
        GigyaSocialLoginService.stub(:new).with({"valid_params" => true, 'gigya_connection' => gigya_connection}) { gigya_social_login_service_stub }
      end

      it 'calls the track_email_capture_event' do

        controller.should_receive(:track_email_capture_event).with(87)

        get :create, {valid_params: true}

        response.should redirect_to dashboard_path
      end

    end

    context 'when the notification to gigya is not successful' do
      let(:unsuccessful_response) { mock('success response', success?: false, message: 'you did it wrong', new_user?: false) }
      let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: unsuccessful_response) }

      before do
        GigyaSocialLoginService.stub(:new).with({"valid_params" => true, 'gigya_connection' => gigya_connection}) { gigya_social_login_service_stub }
      end

      it 'redirects to the homepage' do
        get :create, {valid_params: true}

        flash.notice.should == 'you did it wrong'
        response.should redirect_to root_path
      end
    end
  end
end