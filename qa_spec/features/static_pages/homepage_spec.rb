require 'qa_spec_helper'

describe 'Logged out Home page', js: true do
  pending 'update' do
    before(:each) do
      create_virtual_currency(name: 'Plink Points', subdomain: 'www')
      visit '/'
    end

    subject {page}

    it {should have_text('Be a smarter shopper.') }
    it {should have_text('Join Plink and start earning rewards at over 70,000 locations nationwide.') }
    it {should have_link('Sign In') }
    it {should have_link('Join') }
    it {should have_link('Join Plink for FREE!', count: 2) }

    it 'should allow a guest to view all offers' do
      click_on 'Check out all of our partners'
      page.should have_text('Earn Plink Points at these locations.')
    end

    it 'should allow a guest to view all rewards' do
      click_on 'view rewards'
      page.should have_text('CHOOSE YOUR REWARD.')
    end

    it 'should allow a guest to send an email via the Contact Us form' do
      click_on 'Contact Us'
      page.should have_text('Contact Us')
    end

    it 'should allow the user to like Plink on Facebook' do
      pending 'awaiting deployment' do
        page.should have_css '[gigid="showShareBarUI"]'
        within_frame 'fa7421a30fdeaa' do
          click_on 'submit'
        end
        # Do FB Stuff...within modal, page should ahve text facebook
      end
    end

    it 'should present the user with a link to reset their password' do
        click_on 'Sign In'
        page.should have_link('Forgot Password?')
    end

    context 'when a user is attempting to reset a password' do
      before(:each) do

        click_on 'Sign In'
        click_on 'Forgot Password'
      end

      it 'should error if the email address isnt found' do
        fill_in  'Email', with: 'fake@test.com'
        click_on 'Send Password Reset Instructions'
        page.should have_text 'Sorry this email is not registered with Plink.'
      end

      it 'should send the user an email if their email address is found' do
        create_user(email: 'test@example.com', password: 'test123', first_name: 'QA')

        visit '/'
        click_on 'Sign In'
        click_on 'Forgot Password'
        fill_in  'Email', with: 'test@example.com'
        page.should have_text 'Enter the email address associated with your account. We will send you an e-mail containing instructions for how you can reset your password.'
      end
    end
  end
end