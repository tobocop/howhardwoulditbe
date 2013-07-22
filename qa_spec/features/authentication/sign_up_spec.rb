require 'qa_spec_helper'

describe 'Signing up', js: true do
  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
  end

  it 'lets the user sign up with the regular registration form' do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'test123'
    click_on 'Start Earning Rewards'

    current_path.should == dashboard_path
    page.should have_text('Welcome, Bob!')
  end

  it 'tells the user their password is too short' do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'short'
    fill_in 'Verify Password', with: 'short'
    click_on 'Start Earning Rewards'

    page.should have_text('Please enter a password at least 6 characters long')
  end

  it "tells the user to enter a password confirmation" do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'test123'
    click_on 'Start Earning Rewards'

    page.should have_text('Please confirm your password')
  end

  it "tells the user the password fields don't match" do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'testtest'
    click_on 'Start Earning Rewards'

    page.should have_text('Confirmation password doesn\'t match')
  end

  it 'tells the user the first name field is blank' do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'test123'
    click_on 'Start Earning Rewards'

    page.should have_text('Please enter a First Name')
  end

  it 'tells the user the email field is blank' do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'bob'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'test123'
    click_on 'Start Earning Rewards'

    page.should have_text('Please enter a valid email address')
  end

  it 'tells the user the email field is invalid format' do
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'test123'
    click_on 'Start Earning Rewards'

    page.should have_text('Please enter a valid email address')
  end
  
  it 'tells the user that an email already exists in the database' do
    create_user(email: 'bob@example.com')
    visit '/'
    click_on 'Join'
    click_on 'Join with Email'
    fill_in 'First Name', with: 'Bob'
    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'test123'
    fill_in 'Verify Password', with: 'test123'
    click_on 'Start Earning Rewards'

    page.should have_text(%q{You've entered an email address that is already registered with Plink. If you believe there is an error, please contact support@plink.com.})
  end
end

def delete_user_from_gigya(user_id)
  auth_params = URI.encode_www_form({
                                        apiKey: Gigya::Config.instance.api_key,
                                        secret: Gigya::Config.instance.secret
                                    })

  `/usr/bin/curl -s "https://socialize-api.gigya.com/socialize.deleteAccount?uid=#{user_id}&#{auth_params}"`
end

def delete_users_from_gigya
  User.all.each do |user|
    delete_user_from_gigya(user.id)
  end
end