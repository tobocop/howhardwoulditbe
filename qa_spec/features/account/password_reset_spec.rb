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
    pending 'database fix' do
      fill_in 'Email', with: 'existing@plink.com'
      click_on 'Send Password Reset Instructions'
      page.should have_text "Enter the email address associated with your account. We will send you an e-mail containing instructions for how you can reset your password."
    end
  end
end