require 'spec_helper'

describe 'User signup workflow' do
  before do
    create_virtual_currency
  end

  it 'should create an account and drop the user on the dashboard', js: true do
    visit '/'

    click_link 'Join'

    within '.modal' do
      fill_in 'First Name', with: 'Joe'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Password', with: 'test123'
      fill_in 'Verify Password', with: 'test123'

      click_on 'Start Earning Rewards'
    end

    current_path.should == dashboard_path
    page.should have_content('Welcome, Joe!')
  end
end