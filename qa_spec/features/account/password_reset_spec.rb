require 'qa_spec_helper'

describe 'Password reset request', js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    open_password_reset_page
  end

  subject { page }

  it { should have_text 'Forgot your password?'}
  it { should have_text "Enter the email address associated with your account. We will "\
    "send you an e-mail containing instructions for how you can reset your password." }

  it 'should error with a blank form submission' do
    click_on 'Send Password Reset Instructions'
    page.should have_text 'Sorry this email is not registered with Plink.'
  end

  it 'should error if I enter an email not associated with a Plink user record' do
    fill_in 'Email', with: 'notamember@Plink.com'
    click_on 'Send Password Reset Instructions'
    page.should have_text 'Sorry this email is not registered with Plink.'
  end

  context 'as a Plink member' do
    before { create_user( email: 'email@plink.com', password: 'test123', first_name: 'tester') }

    it 'should send an email if a user enters a legit email address' do
      open_password_reset_page
      fill_in 'password_reset[email]', with: 'email@plink.com'
      click_on 'Send Password Reset Instructions'
      page.should have_text "To reset your password, please follow the "\
        " instructions sent to your email address."
      current_path.should == '/'
    end
  end
end
