require 'spec_helper'

describe RegistrationsController do
  describe "#new" do
    before { UserRegistrationForm.stub(:new) }

    it "should assign @user_registration_form" do
      user_registration_form = stub
      UserRegistrationForm.stub(:new) { user_registration_form }

      get :new
      assigns(:user_registration_form).should == user_registration_form
    end

    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "#create" do
    it "should assign @user_registration_form" do
      user_registration_form = stub(save: nil)
      UserRegistrationForm.stub(:new).with({:first_name => 'frodo', email: 'frod@example.com', password: 'opazz', password_confirmation: 'opazz'}) { user_registration_form }

      post :create, {'first_name' => 'frodo', 'email' => 'frod@example.com', password: 'opazz', password_confirmation: 'opazz'}

      assigns(:user_registration_form).should == user_registration_form
    end

    describe "on save" do
      let(:gigya) { mock }
      let(:cookie_stub) { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

      before do
        controller.stub(:gigya_connection) { gigya }
        gigya.stub(:notify_login) { cookie_stub }
        @user_stub = stub
        user_registration_form = stub(save: true, user: @user_stub, user_id: 123, email: 'test@example.com', first_name: 'bob')
        UserRegistrationForm.stub(:new) { user_registration_form }
        controller.stub(:sign_in_user)
      end

      it "should redirect to the dashboard upon success" do
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}

        post :create, {:user_registration_form => {:post => true}}
        response.location.should =~ /\/dashboard$/
      end

      it "should sign the user in upon success" do
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}

        controller.should_receive(:sign_in_user).with(@user_stub)
        post :create
      end

      it "notifies Gigya of a new user log in" do
        controller.stub(:plink_event_service) {stub(create_email_capture: true)}
        controller.stub(:tracking_params) {stub(to_hash: true)}

        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'bob', email: 'test@example.com', new_user: true) { cookie_stub }
        post :create
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
          ip: request.remote_ip
        )

        post :create
      end
    end

    describe "when registration has errors" do
      it "should re-render the registration form" do
        user_registration_form = stub(save: false)
        UserRegistrationForm.stub(:new) { user_registration_form }

        post :create, {:user_registration_form => {:post => true}}
        response.should be_success
        response.should render_template("registrations/new")
      end
    end
  end
end