require 'spec_helper'

describe 'User signup workflow' do

  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
  end

  context 'organic registration' do
    it 'should create an account, email the user, and drop the user on the wallet page', js: true do
      visit '/'

      click_link 'Join'

      within '.modal' do
        click_on 'Join with Email'

        fill_in 'First Name', with: ''
        fill_in 'Email', with: ''
        fill_in 'Password', with: ''
        fill_in 'Verify Password', with: ''

        click_on 'Start Earning Rewards'
      end

      within '.modal' do
        page.should have_content 'Please provide a First name'
        page.should have_content 'Email address is required'

        fill_in 'First Name', with: 'Joe'
        fill_in 'Email', with: 'test2@example.com'
        fill_in 'Password', with: 'test123'
        fill_in 'Verify Password', with: 'test123'

        click_on 'Start Earning Rewards'
      end

      within ".welcome-text" do
        page.should have_content('Welcome, Joe!')
      end

      current_path.should == wallet_path

      page.should have_css "iframe[src='http://www.plink.dev/index.cfm?fuseaction=intuit.selectInstitution']"

      email = ActionMailer::Base.deliveries.last

      [email.html_part, email.text_part].each do |email_part|
        email_string = Capybara.string(email_part.body.to_s)

        email_string.should have_content 'Welcome and thanks for signing up for Plink'
      end

      page.execute_script('$("#card-add-modal").foundation("reveal", "close")')

      click_on 'Wallet'

      page.should have_content 'My Wallet'
      page.should have_content 'This slot is empty.', count: 3
      page.should have_content 'This slot is locked.', count: 1
    end
  end

  context 'social registration' do
    after(:each) do
      delete_users_from_gigya
    end

    context 'with facebook' do
      it 'allows a user to register with their facebook account', js: true, flaky: true do
        visit '/'

        click_on 'Join'

        within '.modal' do
          page.should have_content 'Join Plink'
        end

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

        page.execute_script('$("#card-add-modal").foundation("reveal", "close")')

        current_path.should == wallet_path

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

        page.execute_script('$("#card-add-modal").foundation("reveal", "close")')

        current_path.should == wallet_path

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
