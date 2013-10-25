require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe GigyaLoginHandlerController do
  describe '#create' do
    let(:gigya_connection) { stub(:gigya_connection) }
    let(:user) { mock('user', id: 55) }
    let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(55 => true) }
    let(:new_gigya_social_login_service_params) {
      {
        'valid_params' => true,
        'gigya_connection' => gigya_connection,
        'ip' => '192.168.0.1',
        'user_agent' => 'my agent'
      }
    }

    before do
      controller.stub(:gigya_connection) { gigya_connection }
      controller.stub(plink_intuit_account_service: fake_intuit_account_service)
      controller.stub(add_user_to_lyris: true)
      controller.stub(current_virtual_currency: mock(:virtual_currency, currency_name: 'Plionk Points'))
      request.stub(remote_ip: '192.168.0.1')
      request.stub(user_agent: 'my agent')
    end

    context 'when successful' do
      context 'and user is found' do
        let(:successful_response) { mock('success response', success?: true, new_user?: false) }
        let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: successful_response) }

        before do
          GigyaSocialLoginService.stub(:new).and_return(gigya_social_login_service_stub)
          controller.should_receive(:sign_in_user).with(user)
        end

        context 'when user has a linked card' do
          let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(55 => true) }

          it 'initializes GigyaSocialLoginService with the correct params' do
            GigyaSocialLoginService.unstub(:new)

            gigya_social_login_service_params = {
              'email' => 'test@example.com',
              'first_name' => 'testing',
              'gigya_connection' => gigya_connection,
              'gigya_id' => '123',
              'ip' => '192.168.0.1',
              'photoURL' => 'http://example.com/image.png',
              'provider' => 'facebook',
              'user_agent' => 'my agent',
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

        context 'when the referer is the contests_path' do
          before { request.env["HTTP_REFERER"] = 'http://test.com/contests' }

          it 'redirects them to the contest path' do
            get :create, {valid_params: true}

            response.should redirect_to contests_path
          end
        end

        it 'does not track an email creation event' do
          get :create, {valid_params: true}
          Plink::EventRecord.all.length.should == 0
        end
      end

      context 'and user is a new user' do
        let(:successful_response) { mock('success response', success?: true, new_user?: true) }
        let(:user_double) { double('user', id: 87, password_hash: 'asd', first_name: 'bobby', email: 'tables@sql.com') }
        let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user_double, sign_in_user: successful_response) }
        let!(:registration_event) { create_event(user_id: nil) }

        before do
          controller.stub(:track_email_capture_event)
          GigyaSocialLoginService.stub(:new).and_return(gigya_social_login_service_stub)
          mock_delay = double('mock_delay').as_null_object
          AfterUserRegistration.stub(:delay).and_return(mock_delay)
        end

        it 'calls the track_email_capture_event' do
          controller.should_receive(:track_email_capture_event).with(87)

          get :create, {valid_params: true}
        end

        it 'updates the registration_start event if the id is present in the session' do
          session[:registration_start_event_id] = registration_event.id

          get :create, {valid_params: true}

          registration_event.reload.user_id.should == 87
        end

        it 'does not update the registration_start event if the id is not present in the session' do
          get :create, {valid_params: true}

          registration_event.reload.user_id.should be_nil
        end

        it 'delays sending a complete your registration email' do
          mock_delay = double('mock_delay').as_null_object
          AfterUserRegistration.should_receive(:delay).and_return(mock_delay)
          mock_delay.should_receive(:send_complete_your_registration_email).with(87)

          get :create, {valid_params: true}
        end

        it 'calls to add the user to lyris' do
          controller.unstub(:add_user_to_lyris)
          delay_double = double(:add_to_lyris)
          Lyris::UserService.should_receive(:delay).and_return(delay_double)
          delay_double.should_receive(:add_to_lyris)
            .with(87, 'tables@sql.com', 'Plionk Points')

          get :create, {valid_params: true}
        end

        it 'signs the user in' do
          get :create, {valid_params: true}

          response.should redirect_to wallet_path(link_card: true)
        end

        context 'when the referer is the contests_path' do
          before { request.env["HTTP_REFERER"] = 'http://test.com/contests' }

          it 'redirects them back to the contest path' do
            get :create, {valid_params: true}

            response.should redirect_to contests_path
          end
        end

        context 'as part of a facebook share flow from a registration link' do
          it 'redirects to the share_page_path when provider is facebook' do
            session[:share_page_id] = 1

            get :create, {valid_params: true, loginProvider: 'facebook', share_page_id: 1}

            response.should redirect_to share_page_path(id: 1)
          end

          it 'does not redirect to the share_page_path when provider is not facebook' do
            session[:share_page_id] = 1

            get :create, {valid_params: true, loginProvider: 'other', share_page_id: 1}

            response.should_not redirect_to share_page_path(id: 1)
          end
        end
      end
    end

    context 'when the notification to gigya is not successful' do
      let(:unsuccessful_response) { mock('success response', success?: false, message: 'you did it wrong', new_user?: false) }
      let(:gigya_social_login_service_stub) { stub(:gigya_login_service, user: user, sign_in_user: unsuccessful_response) }

      before do
        GigyaSocialLoginService.stub(:new).and_return( gigya_social_login_service_stub )
      end

      it 'redirects to the homepage' do
        get :create, {valid_params: true}

        flash.notice.should == 'you did it wrong'
        response.should redirect_to root_path
      end
    end
  end
end
