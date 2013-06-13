require 'spec_helper'

describe 'user signs in' do
  it "lets a registered user sign in" do
    create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob')

    visit '/'
    click_on 'Log in'
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Bob.')
  end
end