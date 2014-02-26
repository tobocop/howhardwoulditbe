require 'spec_helper'

describe 'Managing account' do

  let(:user) { create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image') }
  let!(:virtual_currency) { create_virtual_currency(name: 'Plink Points', subdomain: 'www') }

  context 'linked user' do
    before :each do
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

    context 'active user' do
      it 'allows a user to manage their account', :vcr, js: true, driver: :selenium do
        sign_in('user@example.com', 'pass1word')

        click_link 'My Account'

        within '.profile' do
          page.should have_content 'FRODO'
        end

        page.should have_image 'icon_active.png'
        page.should have_content 'Active'

        within '.content', text: 'YOUR BANK' do
          page.should have_css('a[href="/institutions/search"]', text: 'Change')
          page.should have_content 'Bank of representin'
        end

        page.should have_content 'YOUR CARD'
        page.should have_content 'representing checks 4321'

        page.should have_content 'You have 580 Plink Points.'
        page.should have_content 'LIFETIME STATS Plink Points 880'

        page.should_not have_link 'Redeem'

        page.should have_content 'RECENT ACTIVITY'

        within '.stats-section:nth-of-type(2)' do
          within '.event:nth-of-type(3)' do
            page.should have_content Time.zone.now.to_date.to_s(:month_day)
            page.should have_content 'Walmart Gift Card'
            page.should have_content '-300 Plink Points'
            page.should have_image 'history/icon_redeem.png'
          end

          within '.event:nth-of-type(4)' do
            page.should have_content Time.zone.now.to_date.to_s(:month_day)
            page.should have_content 'for participating in the Plink program'
            page.should have_content '20 Plink Points'
            page.should have_image 'history/icon_bonus.png'
          end

          within '.event:nth-of-type(5)' do
            page.should have_content Time.zone.now.to_date.to_s(:month_day)
            page.should have_content 'Pop Caps inc'
            page.should have_content '425 Plink Points'
            page.should have_image 'history/icon_purchase.png'
          end

          within '.event:nth-of-type(6)' do
            page.should have_content Time.zone.now.to_date.to_s(:month_day)
            page.should have_content 'this is a free award'
            page.should have_content '435 Plink Points'
            page.should have_image 'history/icon_bonus.png'
          end
        end

        within '.content', text: 'user@example.com' do
          page.find('a', text: 'Change').click

          fill_in 'email', with: 'anything@example.com'
          fill_in 'password', with: 'random_stuff'
          click_on 'Change Your Email'
        end

        page.should have_content 'Current password is incorrect'

        within '.content', text: 'user@example.com' do
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

        sign_in('frodo@example.com', 'samwise')

        page.should have_content 'Welcome, samwise!'
      end

      it 'displays a maximum of 20 activities', :vcr, js: true do
        21.times { award_points_to_user(
          user_id: user.id,
          dollar_award_amount: 6,
          currency_award_amount: 600,
          virtual_currency_id: virtual_currency.id,
          award_message: 'My Awards'
        )}

        sign_in('user@example.com', 'pass1word')

        click_on 'My Account'

        page.should have_text('600 Plink Points', count: 20)
      end
    end

    it 'allows a user to change their bank card', :vcr, js: true, driver: :selenium do
      sign_in('user@example.com', 'pass1word')

      click_link 'My Account'
      find('a[href="/institutions/search"]').click

      page.should have_content "Enter your bank's name."
    end
  end

  context 'non linked user' do
    before :each do
      wallet = create_wallet(user_id: user.id)
      create_open_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'allows the user to link one', :vcr, js: true do
      sign_in('user@example.com', 'pass1word')

      page.should have_content "Welcome"

      visit '/account'

      page.should have_image 'icon_alert_pink.png'
      page.should have_content "You haven't linked a card yet."
      page.should have_css('a[href="/institutions/search"]', text: 'Link Card')

      find('a[href="/institutions/search"]').click

      page.should have_content "Enter your bank's name."
    end

    it 'allows a user to unsubscribe from email notifications', :vcr do
      visit new_password_reset_request_path

      fill_in 'Email', with: 'user@example.com'
      click_on 'Send Password Reset Instructions'

      email = ActionMailer::Base.deliveries.last

      email_string = Capybara.string(email.html_part.body.to_s)
      unsubscribe_url = email_string.find("a", text: 'unsubscribe')['href']

      visit unsubscribe_url

      choose 'I no longer wish to receive marketing & promotional emails from Plink(this includes your Account Summary).'

      click_on 'Submit'

      page.should have_css '.flash-msg', text: 'Your subscription preferences have been successfully updated.'
    end

    it 'allows a user to mark an email as spam', :vcr do
      visit new_password_reset_request_path

      fill_in 'Email', with: 'user@example.com'
      click_on 'Send Password Reset Instructions'

      email = ActionMailer::Base.deliveries.last

      email_string = Capybara.string(email.html_part.body.to_s)
      mark_as_spam_url = email_string.find("a", text: 'mark as spam')['href']

      visit mark_as_spam_url

      page.should have_css '.flash-msg', text: 'You have been un-subscribed.'
    end
  end
end
