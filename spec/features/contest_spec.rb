require 'spec_helper'

describe 'Contests' do
  let!(:contest) {
    create_contest(
      description: 'This is the best contest ever',
      end_time: 1.day.from_now.to_date,
      image: '/assets/profile.jpg',
      non_linked_image: '/assets/icon_active.png',
      prize: 'The prize is a new car',
      start_time: 1.day.ago.to_date,
      terms_and_conditions: 'These are terms and conditions'
    )
  }

  before do
    ApplicationController.any_instance.stub(:contest_notification_for_user).and_return(false)
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
  end

  context 'site navigation' do
    it 'adds a link to the contests page for logged in users', js: true do
      visit root_path

      page.should_not have_link 'Contests'

      user = create_user(email: 'user@example.com', password: 'pass1word', first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image')
      create_wallet(user_id: user.id)
      sign_in('user@example.com', 'pass1word')

      page.should have_link 'Contests'
    end
  end

  context 'show view', js: true do
    #This covers the index view as well. They use the same partial to render the contest
    before do
      visit contest_path(contest)
    end

    context 'for a contest that has completed' do
      let(:finalized_timestamp) { 20.minutes.ago }
      let!(:expired_contest) {
        create_contest(
          description: 'Spectacular! Amazing! Best. Contest. Ever.',
          end_time: 2.days.ago.to_date,
          finalized_at: finalized_timestamp,
          image: '/assets/profile.jpg',
          prize: 'A Banana Hammock',
          start_time: 10.days.ago.to_date,
          terms_and_conditions: 'May not be used as an undergarment. (Seriously, Kris.)'
        )
      }

      let!(:grand_prize_winner) { create_user(email: 'matrix@example.com', first_name: 'John', last_name: 'Matrix') }
      let!(:second_prize_winner) { create_user(email: 'cindy@example.com', first_name: 'Cindy') }
      let!(:another_winner) { create_user(email: 'bennett@example.com', first_name: 'Bennett') }

      let!(:grand_prize) { create_contest_prize_level(contest_id: expired_contest.id) }
      let!(:second_prize) { create_contest_prize_level(contest_id: expired_contest.id, dollar_amount: 50) }
      let!(:another_prize) { create_contest_prize_level(contest_id: expired_contest.id, dollar_amount: 2) }

      let!(:contest_winners) do
        create_contest_winner(user_id: grand_prize_winner.id, contest_id: expired_contest.id, prize_level_id: grand_prize.id, winner: true, finalized_at: finalized_timestamp)
        create_contest_winner(user_id: second_prize_winner.id, contest_id: expired_contest.id, prize_level_id: second_prize.id, winner: true, finalized_at: finalized_timestamp)
        create_contest_winner(user_id: another_winner.id, contest_id: expired_contest.id, prize_level_id: another_prize.id, winner: true, finalized_at: finalized_timestamp)
      end

      before do
        visit contest_path(expired_contest)
      end

      it 'displays the contest as expired' do
        page.should have_content 'THIS CONTEST ENDED ON'
        page.should have_link 'View the complete list of winners'
        page.should_not have_link 'share to enter'
        page.should have_css '.image > .overlay-message'
        page.should have_content 'A Banana Hammock:'
        page.should have_content 'JOHN M.'
        page.should have_content 'CINDY'
        page.should_not have_content 'BENNETT'
        click_on 'View the complete list of winners'
        page.should have_content 'Bennett'
        page.should have_content 'A Banana Hammock:', count: 2
      end
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

    it 'displays the individual contest and allows the user to sign up', driver: :selenium do
      page.should have_content 'This is the best contest ever'.upcase
      page.should have_content 'The car is red'
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

      current_url.should include contest_path(contest, share_modal: true)
      page.should have_css('#contest_share_modal')

      click_link 'share to enter'

      within 'div[gigid]' do
        page.should have_content 'Share with your friends'
        page.should have_content 'plink entry post'
        page.should have_content 'enter the contest'
      end

      page.execute_script('$("#contest_share_modal").foundation("reveal", "close")')

      within '.refer' do
        page.find('.footnote').click

        current_path.should == contest_path(contest)
      end
    end

    context 'for an unauthenticated user', js:true do
      it 'only forwards the user to the contest page if the user registers from the contest page', driver: :selenium do
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

        within '.welcome-text' do
          page.should have_content "Welcome, John!"
        end

        current_path.should == institution_search_path
      end

      it 'links to the Referral Program section of the FAQ' do
        page.should have_content 'Get up to 20 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '20 EXTRA ENTRIES'

        click_link '20 EXTRA ENTRIES'

        current_path.should == faq_static_path
        URI.parse(current_url).fragment.should == 'referral-program'

        visit contest_path(contest)

        page.find("[src='/assets/icon_refer.png']").click

        current_path.should == faq_static_path
        URI.parse(current_url).fragment.should == 'referral-program'
      end
    end

    context 'for an authenticated user without a linked card', driver: :selenium do
      let(:user) {
        create_user(
          email: 'user@example.com',
          password: 'pass1word',
          first_name: 'Frodo',
          is_subscribed: true,
          avatar_thumbnail_url: 'http://example.com/image'
        )
      }

      before do
        create_wallet(user_id: user.id)
        sign_in('user@example.com', 'pass1word')

        page.should have_link 'Contests'
        visit contest_path(contest)
      end

      it 'displays the user entry information and allows them to enter' do
        page.should have_content 'You have 0 entries.'
        page.should have_link 'share to enter'
        page.should have_image '/assets/profile.jpg'
        page.should have_content 'Get 5x entries per day when you link a credit or debit card.'
        page.should have_link 'LINK YOUR CARD'

        click_link 'share to enter'
        within 'div[gigid]' do
          page.should have_content 'Share with your friends'
          page.should have_content 'plink entry post'
          page.should have_content 'enter the contest'
        end

        create_entry(contest_id: contest.id, user_id: user.id)
        visit current_path
        page.should have_image '/assets/icon_active.png'

        visit '/contests?card_linked=true'

        page.should have_content "Congratulations! You'll now earn 5X the entries.  Don't forget to add your favorite stores and restaurants to your Wallet and earn rewards for all your purchases."
        page.should have_content 'Get up to 20 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '20 EXTRA ENTRIES'

        click_link '20 EXTRA ENTRIES'

        within 'div[gigid]' do
          page.should have_content 'Join Plink for free and receive 300 bonus points!'
        end
      end
    end

    context 'for an existing user with a linked card' do
      let(:email) { 'user@example.com' }
      let(:password) { 'pass1word' }

      before do
        user = create_user(email: email, password: password, first_name: 'Frodo', is_subscribed: true, avatar_thumbnail_url: 'http://example.com/image')
        create_wallet(user_id: user.id)
        create_oauth_token(user_id: user.id)
        create_users_institution_account(user_id: user.id)
      end

     it 'displays the contest with updated multiplier text' do
        click_on 'Sign In'

        within '.sign-in-modal' do
          page.find('img[alt="Sign in with Email"]').click
          fill_in 'user_session_email', with: email
          fill_in 'user_session_password', with: password
          click_on 'Sign In'
        end

        current_path.should_not == contest_path(contest, link_card: true)
        page.should_not have_css "iframe[src='http://www.plink.dev/index.cfm?fuseaction=intuit.selectInstitution']"

        current_path.should == contest_path(contest)
        page.should have_content "Because you linked a card to your Plink account, you'll get 5x entries per share"
        page.should have_content 'Get up to 100 EXTRA ENTRIES per day for each friend referral'
        page.should have_link '100 EXTRA ENTRIES'
      end
    end
  end
end
