require 'spec_helper'

describe 'Sign In form', js: true do
  before(:each) do
    virtual_currency = create_virtual_currency
    user = create_user( email: 'test@plink.com', password: 'test123', first_name: 'Matt')
    wallet = create_wallet(user_id: user.id)
  end

  it 'throws an error if the user submits an invalid form' do
    sign_in('fakebullshit@plink.com', 'test123')
    page.should have_text('Sorry, the email and password do not match for this account.')

    sign_in('test@plink.com', 'test')
    page.should have_text('Sorry, the email and password do not match for this account.')

    sign_in('', 'test123')
    page.should have_text("Email can't be blank")

    sign_in('test@plink.com', '')
    page.should have_text("Password can't be blank")

    sign_in('test@plink.com', 'test123')
    page.should have_content('Welcome, Matt!')
  end


  it 'allows a user to reset their password' do
    visit new_password_reset_request_path

    page.should have_content 'Enter the email address associated with your account'

    fill_in 'Email', with: 'test@plink.com'

    click_on 'Send Password Reset Instructions'

    page.should have_content 'To reset your password, please follow the instructions sent to your email address.'

    email = ActionMailer::Base.deliveries.last

    email_string = Capybara.string(email.html_part.body.to_s)
    password_reset_url = email_string.find("a", text: 'Reset Password')['href']

    visit password_reset_url

    page.should have_content 'Reset your password'

    fill_in 'New password', with: 'goodpassword'
    fill_in 'Confirm new password', with: 'goodpassword'

    click_on 'Reset Password'

    visit '/'

    sign_in('test@plink.com', 'goodpassword')

    page.should have_content 'Welcome, Matt!'
  end

end
