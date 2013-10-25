require 'spec_helper'

describe RegistrationsController do
  describe "#create" do
    describe "on save" do
      let(:gigya) { mock }
      let(:cookie_stub) { double(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }
      let!(:registration_event) { create_event(user_id: nil) }

      before do
        create_event_type(name: Plink::EventTypeRecord.registration_start_type)
        create_event_type(name: Plink::EventTypeRecord.email_capture_type)

        controller.stub(current_virtual_currency: mock(:virtual_currency, currency_name: 'Plionk Points'))
        controller.stub(:gigya_connection) { gigya }
        gigya.stub(:notify_login) { cookie_stub }
        @user_stub = stub
        user_registration_form = stub(save: true, user: @user_stub, user_id: 123, email: 'test@example.com', first_name: 'bob', ip: '0.0.0.1')
        UserRegistrationForm.stub(:new) { user_registration_form }
        controller.stub(:sign_in_user)
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}
        controller.stub(add_user_to_lyris: true)
      end

      it 'creates a new UserRegistrationForm' do
        create_params = {
          first_name: 'bob',
          email: 'myemail@example.com',
          password: 'password',
          password_confirmation: 'password'
        }

        UserRegistrationForm.should_receive(:new).with(
          create_params.merge(
            virtual_currency_name: 'Plionk Points',
            provider: 'organic',
            ip: request.remote_ip,
            user_agent: request.user_agent
          )
        )

        xhr :post, :create, create_params
      end

      it 'signs the user in upon success' do
        controller.should_receive(:sign_in_user).with(@user_stub)

        xhr :post, :create

        JSON.parse(response.body).should == {'redirect_path' => wallet_path(link_card: true)}
      end

      it "notifies Gigya of a new user log in" do
        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'bob', email: 'test@example.com', new_user: true) { cookie_stub }

        xhr :post, :create
      end

      it 'tracks an email capture event' do
        controller.unstub(:plink_event_service)
        controller.unstub(:tracking_params)

        controller.stub(:session_params) { {affiliate_id: 23986} }
        TrackingObject.should_receive(:new).with(affiliate_id: 23986, ip: request.remote_ip).and_call_original
        Plink::EventService.any_instance.should_receive(:create_email_capture).with(
          123,
          affiliate_id: 23986,
          sub_id: nil,
          sub_id_two: nil,
          sub_id_three: nil,
          sub_id_four: nil,
          path_id: '1',
          campaign_hash: nil,
          campaign_id: nil,
          landing_page_id: nil,
          ip: request.remote_ip
        )

        xhr :post, :create
      end

      it 'updates the registration_start event if the id is present in the session' do
        controller.unstub(:plink_event_service)
        controller.unstub(:tracking_params)

        session[:registration_start_event_id] = registration_event.id

        xhr :post, :create

        registration_event.reload.user_id.should == 123
      end

      it 'does not update the registration_start event if the id is not present in the session' do
        xhr :post, :create

        registration_event.reload.user_id.should be_nil
      end

      it 'calls to add the user to lyris' do
        controller.unstub(:add_user_to_lyris)
        delay_double = double(:add_to_lyris)
        Lyris::UserService.should_receive(:delay).and_return(delay_double)
        delay_double.should_receive(:add_to_lyris)
          .with(123, 'test@example.com', 'Plionk Points')
        xhr :post, :create
      end

      it 'returns the user to the contests path if that is where they were referred from' do
        request.env["HTTP_REFERER"] = 'http://test.com/contests'

        xhr :post, :create

        JSON.parse(response.body).should == {'redirect_path' => contests_path}
      end
    end

    describe "when registration has errors" do
      before do
        controller.stub(current_virtual_currency: mock(:virtual_currency, currency_name: 'Plionk Points'))
      end

      it "should return an erroneous json response" do
        xhr :post, :create

        response.status.should == 403

        JSON.parse(response.body).should == {
          'errors' => {
            'first_name' => ["Please provide a First name"],
            'password' => ["Please enter a password at least 6 characters long"],
            'password_confirmation' => ["Please confirm your password"],
            'email' => ["Email address is required", "Please enter a valid email address"]
          }
        }
      end
    end
  end
end
