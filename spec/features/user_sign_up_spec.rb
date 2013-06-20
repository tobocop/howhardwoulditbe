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

    it 'should show error messages when form validation fails', js: true do
      visit '/'

      click_link 'Join'

      within '.modal' do
        click_on 'Start Earning Rewards'
      end

      page.should have_text('Password is too short (minimum is 6 characters)')
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
        fill_in 'Email or Phone:', with: "matt.hamrick@plink.com"
        fill_in 'Password:', with: 'test123'

        click_button 'Log In'
      end

      current_path.should == dashboard_path
      page.should have_content('Welcome, Matt!')

      delete_users_from_gigya
    end
  end
end

def delete_users_from_gigya
  auth_params = URI.encode_www_form({
                                        apiKey: Gigya::Config.instance.api_key,
                                        secret: Gigya::Config.instance.secret
                                    })

  User.all.each do |user|
    `/usr/bin/curl -s "https://socialize-api.gigya.com/socialize.deleteAccount?uid=#{user.id}&#{auth_params}"`
  end
end