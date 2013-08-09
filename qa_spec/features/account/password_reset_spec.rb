require 'qa_spec_helper'

describe 'Password reset request', js: true do
  subject { page }

  context 'as a Plink guest' do
    before(:each) do
      open_password_reset_page
    end

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
  end

  context 'as a Plink member' do
    before { sign_up_user('matt', 'email@plink.com', 'test123') }

    it 'should send an email if a user enters a legit email address' do
      click_on 'Log Out'
      open_password_reset_page
      fill_in 'password_reset[email]', with: 'email@plink.com'
      click_on 'Send Password Reset Instructions'
      page.should have_text "To reset your password, please follow the "\
        " instructions sent to your email address."
      current_path.should == '/'
    end
  end
end
