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
      UserRegistrationForm.stub(:new).with({"post" => true}) { user_registration_form }

      post :create, {:user_registration_form => {"post" => true}}
      assigns(:user_registration_form).should == user_registration_form
    end

    describe "on save" do
      let(:gigya) { mock }
      let(:cookie_stub) { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

      before do
        controller.stub(:gigya_connection) { gigya }
        gigya.stub(:notify_login) { cookie_stub }
      end

      it "should redirect to the dashboard upon success" do
        user_registration_form = stub(save: true, user: stub, user_id: 123, email:'test@example.com', first_name:'bob')
        UserRegistrationForm.stub(:new) { user_registration_form }
        controller.stub(:sign_in_user)

        post :create, {:user_registration_form => {:post => true}}
        response.location.should =~ /\/dashboard$/
      end

      it "should sign the user in upon success" do
        user_stub = stub
        user_registration_form = stub(save: true, user: user_stub, user_id: 123, email:'test@example.com', first_name:'bob')
        UserRegistrationForm.stub(:new) { user_registration_form }

        controller.should_receive(:sign_in_user).with(user_stub)
        post :create
      end

      it "notifies Gigya of a new user log in" do
        user_stub = stub
        user_registration_form = stub(save: true, user: user_stub, user_id: 123, email:'bob@example.com', first_name:'Bob')
        UserRegistrationForm.stub(:new) { user_registration_form }
        controller.stub(:sign_in_user)

        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'Bob', email: 'bob@example.com', new_user: true) { cookie_stub }

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