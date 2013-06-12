require 'spec_helper'

describe 'User signup workflow' do
  it "should create an account and drop the user on the dashboard" do
    User.find_by_email("test@example.com").should_not be
    visit '/'

    click_on 'Sign in'
    fill_in "First name", with: "Joe"
    fill_in "Email", with: "test@example.com"
    fill_in "Password", with: "test123"
    fill_in "Verify password", with: "test123"
    click_on "Register"

    User.find_by_email("test@example.com").should be

    request.should redirect_to("/esgseflks")
  end
end