require 'spec_helper'

describe 'User signup workflow' do

  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
  end

  context 'organic registration' do
    it 'should create an account and drop the user on the dashboard', js: true do
      visit '/'

      click_link 'Join'

      within '.modal' do
        fill_in 'First Name', with: 'Joe'
        fill_in 'Email', with: 'test2@example.com'
        fill_in 'Password', with: 'test123'
        fill_in 'Verify Password', with: 'test123'

        click_on 'Start Earning Rewards'
      end

      page.should have_content('Welcome, Joe!')
      current_path.should == dashboard_path

      click_on 'Wallet'

      page.should have_content 'My Wallet'
      page.should have_content 'This slot is empty.', count: 3
      page.should have_content 'This slot is locked.', count: 1
    end

    it 'should show error messages when form validation fail', js: true do

      pending 'rewriting how this works'

      visit '/'

      click_link 'Join'

      page.should have_content 'Start Earning Rewards'

      within '.modal' do
        click_on 'Start Earning Rewards'
      end

      page.should have_text('Please enter a password at least 6 characters long')
    end
  end

  context 'social registration' do
    after(:each) do
      delete_users_from_gigya
    end

    context 'with facebook' do
      it 'allows a user to register with their facebook account', js: true do
        visit '/'

        click_on 'Join'

        page.should have_content 'Join Plink'

        within '.modal' do
          page.find('[gigid="facebook"]').click
        end

        within_window page.driver.browser.window_handles.last do
          page.should have_content 'Password'
          fill_in 'Email', with: 'matt.hamrick@plink.com'
          fill_in 'Password:', with: 'test123'
          click_button 'Log In'
        end

        page.should have_content('Welcome, Matt!')
        current_path.should == dashboard_path

        click_on 'Wallet'

        page.should have_content 'My Wallet'
        page.should have_content 'This slot is empty.', count: 3
        page.should have_content 'This slot is locked.', count: 1
      end
    end

    context 'with twitter' do
      it 'allows a user to register with their twitter account', js: true, flaky: true do
        visit '/'

        click_on 'Join'

        page.should have_content 'Join Plink'

        within '.modal' do
          page.find('[gigid="twitter"]').click
        end

        within_window page.driver.browser.window_handles.last do

          page.should have_content 'Username or email'

          fill_in 'Username or email', with: 'mattplink'
          fill_in 'Password', with: 'test123'

          click_button 'Authorize app'
        end

        page.should have_content 'Email'

        fill_in 'profile.email', with: 'matt@example.com'
        click_button 'Submit'

        page.should have_content('Welcome, Matt!')
        current_path.should == dashboard_path

        click_on 'Wallet'

        page.should have_content 'My Wallet'
        page.should have_content 'This slot is empty.', count: 3
        page.should have_content 'This slot is locked.', count: 1
      end
    end
  end

  context 'referral' do
    it 'lands the user on the homepage after being referred' do
      referrer = create_user
      visit "/refer/#{referrer.id}/aid/1264"

      current_path.should == root_path
    end
  end
end
