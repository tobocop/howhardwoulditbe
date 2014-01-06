require 'spec_helper'

describe 'Contest notifications' do
  before do
    create_virtual_currency
    create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
  end

  context 'daily reminder notification', js: true do
    let!(:contest) {
      create_contest(
        description: 'Fortune Cookie Contest',
        end_time: 2.days.from_now,
        image: '/assets/profile.jpg',
        prize: 'Fortune Cookie',
        start_time: 10.days.ago.to_date,
        terms_and_conditions: 'We are not responsible for the outcome of your fortune',
        entry_notification: 'enter this contest or else'
      )
    }

    it 'reminds a user to enter the contest, displays the prize, and links to the contest page.' do
      sign_up_user('matt', 'm@p.c', '123123')
      page.should have_content 'enter this contest or else'

      click_on 'GO TO CONTEST'
      current_path.should == contests_path

      click_on 'Log Out'
      sign_in('m@p.c', '123123')

      page.should_not have_content 'enter this contest or else'
    end
  end

  context 'winning notification', js: true do
    let(:finalized_timestamp) { 20.minutes.ago }
    let!(:expired_contest) {
      create_contest(
        description: 'Spectacular! Amazing! Best. Contest. Ever.',
        end_time: 2.days.ago.to_date,
        finalized_at: finalized_timestamp,
        image: '/assets/profile.jpg',
        prize: 'The prize is a slightly used banana hammock.',
        start_time: 10.days.ago.to_date,
        terms_and_conditions: 'May not be used as an undergarment. (Seriously, Kris.)'
      )
    }
    let!(:grand_prize_winner) { create_user(email: 'matrix@example.com', first_name: 'John', last_name: 'Matrix', password: 'test123') }
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

    it 'shows to a contest winner, allows them to share, and links to the contest page' do
      sign_in(grand_prize_winner.email, 'test123')

      page.should have_content "You've won 10000 Plink Points. Share with your friends."
      page.should have_css '.primary-action'

      click_on 'Tell Your Friends'
      within 'div[gigid]' do
        page.should have_content 'Share with your friends'
      end

      click_on 'View Full Contest Results'
      current_path.should == contest_path(expired_contest)
    end
  end
end
