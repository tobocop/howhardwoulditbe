require 'spec_helper'

describe 'Managing account' do

  let(:user) {create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true)}

  context 'linked user' do
    before(:each) do
      virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')

      wallet = create_wallet(user_id: user.id)
      create_open_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)

      create_oauth_token(user_id: user.id)
      users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
      institution = create_institution(name: 'Bank of representin')
      users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
      create_users_institution_account(user_id: user.id, name: 'representing checks', users_institution_id: users_institution.id, account_number_last_four: 4321)

      advertiser = create_advertiser(advertiser_name: 'Pop Caps inc')

      award_points_to_user(
        user_id: user.id,
        dollar_award_amount: 4.35,
        currency_award_amount: 435,
        award_message: 'this is a free award',
        virtual_currency_id: virtual_currency.id,
        type: 'free'
      )

      award_points_to_user(
        user_id: user.id,
        dollar_award_amount: 4.25,
        currency_award_amount: 425,
        virtual_currency_id: virtual_currency.id,
        users_virtual_currency_id: users_virtual_currency.id,
        advertiser_id: advertiser.id,
        type: 'qualifying'
      )

      award_points_to_user(
        user_id: user.id,
        dollar_award_amount: 0.20,
        currency_award_amount: 20,
        virtual_currency_id: virtual_currency.id,
        users_virtual_currency_id: users_virtual_currency.id,
        advertiser_id: advertiser.id,
        type: 'nonqualifying'
      )

      reward = create_reward(name: 'Walmart Gift Card')
      create_redemption(reward_id: reward.id, user_id: user.id, dollar_award_amount: 3.00)
    end

    context 'user that needs to reverify' do
      before(:each) do
        create_user_reverification(user_id: user.id)
      end

      it 'allows the user to reverify' do
        sign_in('user@example.com', 'pass1word')

        click_link 'My Account'

        page.should have_image 'icon_alert_pink.png'
        page.should have_content 'Inactive'
        page.should have_css('a[data-reveal-id="card-add-modal"]', text: 'Reverify')
      end
    end

    context 'active user' do
      it 'allows a user to manage their account', js: true, driver: :selenium do
        sign_in('user@example.com', 'pass1word')

        click_link 'My Account'

        page.should have_image 'icon_active.png'
        page.should have_content 'Active'

        within '.content', text: 'YOUR BANK' do
          page.should have_css('a[data-reveal-id="card-change-modal"]', text: 'Change')
          page.should have_content 'Bank of representin'
        end

        page.should have_content 'YOUR CARD'
        page.should have_content 'representing checks 4321'

        page.should have_content 'You have 580 Plink Points.'
        page.should have_content 'Lifetime balance: 880 Plink Points'

        page.should_not have_link 'Redeem'

        page.should have_content 'RECENT ACTIVITY'

        within '.activity' do
          within '.event:nth-of-type(2)' do
            page.should have_content Date.today.to_s(:month_day)
            page.should have_content 'Walmart Gift Card'
            page.should have_content '-300 Plink Points'
            page.should have_image 'history/icon_redeem.png'
          end

          within '.event:nth-of-type(3)' do
            page.should have_content Date.today.to_s(:month_day)
            page.should have_content 'for participating in the Plink program'
            page.should have_content '20 Plink Points'
            page.should have_image 'history/icon_bonus.png'
          end

          within '.event:nth-of-type(4)' do
            page.should have_content Date.today.to_s(:month_day)
            page.should have_content 'Pop Caps inc'
            page.should have_content '425 Plink Points'
            page.should have_image 'history/icon_purchase.png'
          end

          within '.event:nth-of-type(5)' do
            page.should have_content Date.today.to_s(:month_day)
            page.should have_content 'this is a free award'
            page.should have_content '435 Plink Points'
            page.should have_image 'history/icon_bonus.png'
          end
        end

        within '.content', text: 'user@example.com' do
          page.find('a', text: 'Change').click

          fill_in 'email', with: 'frodo@example.com'
          fill_in 'password', with: 'pass1word'
          click_on 'Change Your Email'
        end

        page.should have_content 'frodo@example.com'

        within '.content', text: 'EMAIL PREFERENCES' do
          page.should have_checked_field 'I want to hear about deals and promotions from Plink via email'
          uncheck 'I want to hear about deals and promotions from Plink via email'
        end

        page.should have_css '.flash-msg', text: 'Account updated successfully'

        within '.content', text: 'EMAIL PREFERENCES' do
          check 'I want to hear about deals and promotions from Plink via email'
        end

        page.should have_css '.flash-msg', text: 'Account updated successfully'

        within '.content', text: 'NAME' do
          page.find('a', text: 'Change').click

          fill_in 'first_name', with: 'samwise'
          fill_in 'password', with: 'pass1word'
          click_on 'Change Your Name'
        end

        within '.flash-msg' do
          page.should have_content 'Account updated successfully'
        end

        page.should have_content 'samwise'

        within '.content', text: 'PASSWORD' do
          page.find('a', text: 'Change').click

          fill_in 'new_password', with: 'samwise'
          fill_in 'new_password_confirmation', with: 'samwise'
          fill_in 'password', with: 'pass1word'
          click_on 'Change Your Password'
        end

        click_on 'Log Out'

        click_on 'Sign In'

        fill_in 'Email', with: 'frodo@example.com'
        fill_in 'Password', with: 'samwise'
        click_on 'Log in'

        page.should have_content 'Welcome, samwise!'
      end

      it 'allows a user to reset their password' do
        visit '/'

        click_on 'Sign In'

        click_link 'Forgot Password?'

        page.should have_content 'Enter the email address associated with your account'

        fill_in 'Email', with: 'user@example.com'

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

        click_on 'Sign In'

        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: 'goodpassword'

        click_on 'Log in'

        page.should have_content 'Welcome, Frodo!'
      end

    end
  end

  context 'non linked user' do
    before do
      create_virtual_currency(name: 'Plink Points', subdomain: 'www')

      wallet = create_wallet(user_id: user.id)
      create_open_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'allows the user to link one' do
      sign_in('user@example.com', 'pass1word')

      click_link 'My Account'

      page.should have_image 'icon_alert_pink.png'
      page.should have_content "You haven't linked a card yet."
      page.should have_css('a[data-reveal-id="card-add-modal"]', text: 'Link Card')
    end
  end
end
