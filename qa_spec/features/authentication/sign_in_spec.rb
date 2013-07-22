require 'qa_spec_helper'

describe 'Signing in', js: true do

  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'Matt')
  end

  it 'lets the user sign in with an existing Plink account' do
    visit '/'
    
    click_on "Sign In"
    fill_in 'Email', with: 'qa_spec_test@example.com'
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Matt!')
  end

  it 'throws an error if the user attempts to log in with a non-existent account' do
    visit '/'
    click_on "Sign In"
    fill_in 'Email', with: 'iamnotarealaccount@plinkplink.com'
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    page.should have_text('Email or password is invalid')
  end

  it 'tells the user if password is incorrect' do
    visit '/'
    click_on "Sign In"
    fill_in 'Email', with: 'qa_spec_test@example.com'
    fill_in 'Password', with: 'test'
    click_on 'Log in'

    page.should have_text('Email or password is invalid')
  end

  it 'tells the user if email field is blank' do
    visit '/'
    click_on "Sign In"
    fill_in 'Email', with: ''
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    page.should have_text("Email can't be blank")
  end

  it 'tells the user if password field is blank' do
    visit '/'
    click_on "Sign In"
    fill_in 'Email', with: 'qa_spec_test@example.com'
    fill_in 'Password', with: ''
    click_on 'Log in'

    page.should have_text("Password can't be blank")
  end
end

describe 'Logging out', js: true do 
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'Matt')
  end

  it 'lets the user sign in with an existing Plink account' do
    visit '/'
    click_on "Sign In"
    fill_in 'Email', with: 'qa_spec_test@example.com'
    fill_in 'Password', with: 'test123'
    click_on 'Log in'

    click_on 'Log Out'
    current_path.should == '/'
    page.should have_text('You have been successfully logged out.')
  end

  it 'blocks the dashboard for non-authenticated guests' do
    visit '/dashboard'
    current_path.should == '/'
  end
end













