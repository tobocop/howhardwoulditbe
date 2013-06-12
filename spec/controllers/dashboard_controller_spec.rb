require 'spec_helper'

describe DashboardController do
  it "renders the dashboard" do
    get :show
    response.should be_success
  end
end