require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe GigyaLoginHandlerController do
  describe '#create' do
    let(:gigya_connection) { stub(:gigya_connection) }
    let(:user) { mock('user', id: 55) }
    let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(55 => true) }
    let(:new_gigya_social_login_service_params) {
      {
        "valid_params" => true,
        'gigya_connection' => gigya_connection,
        "ip" => '192.168.0.1'
      }
    }

    before do
      controller.stub(:gigya_connection) { gigya_connection }
      controller.stub(plink_intuit_account_service: fake_intuit_account_service)
      request.stub(remote_ip: '192.168.0.1')
    end


    context 'when successful' do
      context 'and user is found' do
        let(:successful_response) { mock('success response', success?: true, new_user?: false) }
        let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: successful_response) }

        before do
          GigyaSocialLoginService.stub(:new).with(new_gigya_social_login_service_params) { gigya_social_login_service_stub }
          controller.should_receive(:sign_in_user).with(user)
        end

        context 'when user has a linked card' do
          let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(55 => true) }

          it 'initializes GigyaSocialLoginService with the correct params' do
            GigyaSocialLoginService.unstub(:new)

            gigya_social_login_service_params = {
              'gigya_id' => '123',
              'email' => 'test@example.com',
              'first_name' => 'testing',
              'photoURL' => 'http://example.com/image.png',
              'provider' => 'facebook',
              'gigya_connection' => gigya_connection,
              'ip' => '192.168.0.1'
            }

            GigyaSocialLoginService.should_receive(:new).with(gigya_social_login_service_params) { gigya_social_login_service_stub }

            get :create, {
              gigya_id: '123',
              email: 'test@example.com',
              first_name: 'testing',
              photoURL: 'http://example.com/image.png',
              provider: 'facebook'
            }

            response.should redirect_to wallet_path
          end

          it 'redirects to the wallet page' do
            get :create, {valid_params: true}

            response.should redirect_to wallet_path
          end
        end

        context 'when the user has not yet linked a card' do
          let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(55 => false) }

          it 'redirects to the wallet path with the link card param' do
            get :create, {valid_params: true}

            response.should redirect_to wallet_path(link_card: true)
          end

        end

        it 'does not track an email creation event' do
          get :create, {valid_params: true}
          Plink::EventRecord.all.length.should == 0
        end
      end

      context 'and user is a new user' do
        let(:successful_response) { mock('success response', success?: true, new_user?: true) }
        let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: mock('user', id: 87, password_hash: 'asd'), sign_in_user: successful_response) }

        before do
          controller.stub(:track_email_capture_event)
          GigyaSocialLoginService.stub(:new).with(new_gigya_social_login_service_params) { gigya_social_login_service_stub }
        end

        it 'calls the track_email_capture_event' do
          controller.should_receive(:track_email_capture_event).with(87)

          get :create, {valid_params: true}
        end

        it 'signs the user in' do
          get :create, {valid_params: true}

          response.should redirect_to wallet_path(link_card: true)
        end
      end
    end


    context 'when the notification to gigya is not successful' do
      let(:unsuccessful_response) { mock('success response', success?: false, message: 'you did it wrong', new_user?: false) }
      let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: unsuccessful_response) }

      before do
        GigyaSocialLoginService.stub(:new).with(new_gigya_social_login_service_params) { gigya_social_login_service_stub }
      end

      it 'redirects to the homepage' do
        get :create, {valid_params: true}

        flash.notice.should == 'you did it wrong'
        response.should redirect_to root_path
      end
    end
  end
end
