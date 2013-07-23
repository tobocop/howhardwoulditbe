require 'qa_spec_helper'

describe 'Password reset request', js: true do 
  before(:each) do
    create_user(password:'password', email: 'existing@plink.com')

    visit '/'
    click_on 'Sign In'
    click_on 'Forgot Password?'
  end

  subject { page }

  it { should have_field 'Email' }

  it 'should reject invalid emails' do
    fill_in 'Email', with: 'invalidemail'
    click_on 'Send Password Reset Instructions'
    page.should have_text 'Sorry this email'
  end

  it 'should sent a reset email to a valid user' do
    fill_in 'Email', with: 'existing@plink.com'
    click_on 'Send Password Reset Instructions'
    page.should have_text "To reset your password, please follow the instructions sent to your email address."
  end
end