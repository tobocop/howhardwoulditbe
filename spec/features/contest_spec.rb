require 'spec_helper'

describe 'Contests' do
  let!(:contest) {
    create_contest(
      description: 'This is the best contest ever',
      prize: 'The prize is a new car',
      start_time: 1.day.ago.to_date,
      end_time: 1.day.from_now.to_date,
      terms_and_conditions: 'These are terms and conditions',
      image: '/assets/profile.jpg'
    )
  }

  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
  end

  context 'site navigation' do
    it 'doesn\'t add a link for a non-logged in user' do
      visit root_path

      page.should_not have_link 'Contests'
    end

    it 'adds a link to the contests page for logged in users', js: true do
      user = create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image')
      create_wallet(user_id: user.id)
      sign_in('user@example.com', 'pass1word')

      page.should have_link 'Contests'
    end
  end

  context 'show view', js: true, driver: :selenium do
    #This covers the index view as well. They use the same partial to render the contest
    before do
      visit contest_path(contest)
    end

    context 'for a contest that has not started' do
      let(:future_contest) { create_contest(start_time: 2.days.from_now.to_date, end_time: 3.days.from_now.to_date) }

      before do
        visit contest_path(future_contest)
      end

      it 'displays a message to the user to check back soon' do
        page.should have_content 'Contest has not started yet, please check back soon.'
        page.should_not have_link 'share to enter'
      end
    end

    it 'displays the individual contest and allows the user to sign up' do
      page.should have_content 'This is the best contest ever'.upcase
      page.should have_content 'The prize is a new car'
      page.should have_image '/assets/profile.jpg'

      click_on 'Contest Rules'
      page.should have_content 'These are terms and conditions'

      first('.header-button').click_link('Join')

      within '.sign-in-modal' do
        page.find('img[alt="Register with Email"]').click

        fill_in 'First Name', with: 'John'
        fill_in 'Email', with: 'example@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Verify Password', with: 'password'
        click_on 'Start Earning Rewards'
      end

      within '.welcome-text' do
        page.should have_content "Welcome, John!"
      end

      Plink::UserRecord.last.first_name.should == 'John'
      Plink::UserRecord.last.email.should == 'example@example.com'

      current_path.should == contest_path(contest)

      within '.refer' do
        page.find('.footnote').click

        current_path.should == contest_path(contest)
        assert page.driver.browser.window_handles.size == 2
      end
    end

    context 'for an unauthenticated user', js:true do
      it 'only forwards the user to the contest page if the user logs in from the contest page' do
        visit '/'

        page.should have_content "Join"

        first('.header-button').click_link('Join')

        within '.sign-in-modal' do
          page.find('img[alt="Register with Email"]').click

          fill_in 'First Name', with: 'John'
          fill_in 'Email', with: 'example@example.com'
          fill_in 'Password', with: 'password'
          fill_in 'Verify Password', with: 'password'
          click_on 'Start Earning Rewards'
        end

        page.should have_content "Welcome, John!"

        current_path.should == '/wallet'
      end

      it 'links to the Referral Program section of the FAQ from the referral text' do
        page.should have_content 'Get up to 20 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '20 EXTRA ENTRIES'

        click_link '20 EXTRA ENTRIES'

        current_path.should == faq_static_path
        URI.parse(current_url).fragment.should == 'referral-program'
      end

      it 'links to the Referral Program section of the FAQ from the referral icon' do
        page.find("[src='/assets/icon_refer.png']").click

        current_path.should == faq_static_path
        URI.parse(current_url).fragment.should == 'referral-program'
      end
    end

    context 'for an authenticated user without a linked card', js: true, driver: :selenium do
      before do
        user = create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image')
        create_wallet(user_id: user.id)
        sign_in('user@example.com', 'pass1word')

        page.should have_link 'Contests'
        visit contest_path(contest)
      end

      it 'displays the user entry information and allows them to enter' do
        page.should have_content 'You have 0 entries.'
        page.should have_link 'share to enter'
        page.should have_content 'Get 5x entries per day when you link a credit or debit card.'
        page.should have_css('a[data-reveal-id="card-add-modal"]', text: 'link a credit or debit card')
        # This event is triggered via coldfusion:
        page.execute_script('$(document).trigger("cardLinkProcessComplete");')

        page.should have_content "Congratulations! You'll now earn 5X the entries.  Don't forget to add your favorite stores and restaurants to your Wallet and earn rewards for all your purchases."
        page.should have_content 'Get up to 20 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '20 EXTRA ENTRIES'

        click_link '20 EXTRA ENTRIES'

        within 'div[gigid]' do
          page.should have_content 'Join Plink for free and receive a $5 gift card'
        end
      end

      context 'entering the contest' do
        before { click_link 'share to enter' }

        it 'presents the share modal' do
          within 'div[gigid]' do
            page.should have_content 'Share with your friends'
          end
        end
      end
    end

    context 'for an authenticated user with a linked card' do
      before do
        user = create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image')
        create_wallet(user_id: user.id)
        create_oauth_token(user_id: user.id)
        create_users_institution_account(user_id: user.id)

        sign_in('user@example.com', 'pass1word')

        page.should have_link 'Contests'
        click_link 'Contests'
      end

     it 'displays the user the contest with the updated multiplier text' do
        page.should have_content "Because you linked a card to your Plink account, you'll get 5x entries per share"
        page.should have_content 'Get up to 100 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '100 EXTRA ENTRIES'
      end
    end
  end
end
