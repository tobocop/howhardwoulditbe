require 'spec_helper'

describe RegistrationsController do
  describe "#create" do
    describe "on save" do
      let(:gigya) { mock }
      let(:cookie_stub) { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

      before do
        controller.stub(current_virtual_currency: mock(:virtual_currency, currency_name: 'Plionk Points'))
        controller.stub(:gigya_connection) { gigya }
        gigya.stub(:notify_login) { cookie_stub }
        @user_stub = stub
        user_registration_form = stub(save: true, user: @user_stub, user_id: 123, email: 'test@example.com', first_name: 'bob')
        UserRegistrationForm.stub(:new) { user_registration_form }
        controller.stub(:sign_in_user)
      end

      it "should sign the user in upon success" do
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}

        controller.should_receive(:sign_in_user).with(@user_stub)

        xhr :post, :create

        JSON.parse(response.body).should == {'redirect_path' => wallet_path(link_card: true)}
      end

      it "notifies Gigya of a new user log in" do
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}

        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'bob', email: 'test@example.com', new_user: true) { cookie_stub }

        xhr :post, :create
      end

      it 'tracks an email capture event' do
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
          ip: request.remote_ip
        )

        xhr :post, :create
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
          'error_message' => 'Please Correct the below errors:',
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
