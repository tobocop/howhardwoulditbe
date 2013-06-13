require 'spec_helper'

describe ApplicationController do
  describe "#sign_in_user" do
    it "sets the current_user_id cookie" do
      user = mock_model(User, id: 123)
      controller.sign_in_user(user)
      session[:current_user_id].should == 123
    end
  end

  describe "#current_user" do
    it "returns the current user" do
      session[:current_user_id] = 3
      user = stub
      User.should_receive(:find).with(3) { user }

      controller.current_user.should == user
    end
  end
end