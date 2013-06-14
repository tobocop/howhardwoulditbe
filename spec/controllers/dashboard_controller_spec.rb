require 'spec_helper'

describe DashboardController do
  it "renders the dashboard if a current user exists" do
    controller.stub(:require_authentication) { true }
    get :show
    response.should be_success
  end

  it "redirects to the home page if the user is not logged in" do
    get :show
    response.should be_redirect
  end
end