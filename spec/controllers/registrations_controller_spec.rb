require 'spec_helper'

describe RegistrationsController do
  describe "#new" do
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

    it "should redirect to the dashboard upon success" do
      user_registration_form = stub(save: true, user: stub)
      UserRegistrationForm.stub(:new) { user_registration_form }
      controller.stub(:sign_in_user)

      post :create, {:user_registration_form => {:post => true}}
      response.location.should =~ /\/dashboard$/
    end

    it "should sign the user in upon success" do
      user_stub = stub
      user_registration_form = stub(save: true, user: user_stub)
      UserRegistrationForm.stub(:new) { user_registration_form }

      controller.should_receive(:sign_in_user).with(user_stub)
      post :create
    end

    it "should re-render the registration form if there is an error" do
      user_registration_form = stub(save: false)
      UserRegistrationForm.stub(:new) { user_registration_form }

      post :create, {:user_registration_form => {:post => true}}
      response.should be_success
      response.should render_template("registrations/new")
    end
  end
end