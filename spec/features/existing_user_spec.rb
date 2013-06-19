require 'spec_helper'

describe 'user signs in' do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob')
  end

  it 'a registered user can have an active session', js: true do
    visit '/'

    click_on 'Sign In'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'test123'

    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Bob!')
    page.should have_content('You have 0 Plink Points.')

    click_on 'Log Out'

    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')
  end
end