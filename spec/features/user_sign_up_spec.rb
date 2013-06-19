require 'spec_helper'

describe 'User signup workflow' do

  before do
    create_virtual_currency
  end

  context 'organic registration' do
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

  context 'registering with facebook' do
    it 'allows a user to register with their facebook account', js: true do
      visit '/'

      click_on 'Join'

      page.should have_content 'Join Plink'

      within '.modal' do
        page.find('[gigid="facebook"]').click
      end

      within_window page.driver.browser.window_handles.last do
        page.should have_content 'Email or Phone'
        fill_in 'Email or Phone:', with: 'matt.hamrick@plink.com'
        fill_in 'Password:', with: 'test123'

        click_button 'Log In'
      end

      current_path.should == dashboard_path
      page.should have_content('Welcome, Matt!')
    end
  end
end