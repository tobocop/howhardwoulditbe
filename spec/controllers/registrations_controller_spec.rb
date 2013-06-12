require 'spec_helper'

describe RegistrationsController do
  describe "#new" do
    it "should assign @user" do
      user = stub
      User.stub(:new) { user }

      get :new
      assigns(:user).should == user
    end

    it "should be successful" do
      get :new
      response.should be_success
    end
  end
end