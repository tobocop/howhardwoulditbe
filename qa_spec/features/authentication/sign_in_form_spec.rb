require 'qa_spec_helper'

describe 'Sign In form', js: true do
  before(:each) do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    user = create_user( email: 'test@plink.com', password: 'test123', first_name: 'Matt')
    wallet = create_wallet(user_id: user.id)
  end

  it 'lets the user sign in with an existing Plink account' do
    sign_in_user('test@plink.com', 'test123')
    page.should have_content('Welcome, Matt!')
  end

  it 'throws an error if the user attempts to log in with a non-existent account' do
    sign_in_user('fakebullshit@plink.com', 'test123')
    page.should have_text('Sorry, the email and password do not match for this account.')
  end

  it 'tells the user if password is incorrect' do
    sign_in_user('test@plink.com', 'test')
    page.should have_text('Sorry, the email and password do not match for this account.')
  end

  it 'tells the user if email field is blank' do
    sign_in_user('', 'test123')
    page.should have_text("Email can't be blank")
  end

  it 'tells the user if password field is blank' do
    sign_in_user('test@plink.com', '')
    page.should have_text("Password can't be blank")
  end

  it 'signs out a logged in user' do
    sign_in_user('test@plink.com', 'test123')
    click_on 'Log Out'
    current_path.should == '/'
    page.should have_text('You have been successfully logged out.')
  end
end
