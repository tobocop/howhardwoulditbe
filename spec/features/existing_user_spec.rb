require 'spec_helper'

describe 'user signs in' do
  it "a registered user can have an active session" do
    create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob')

    visit '/'
    click_on 'Log in'
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Bob.')

    click_on 'Log out'
    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')
  end
end