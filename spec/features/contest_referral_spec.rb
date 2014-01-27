require 'spec_helper'

describe 'contest referral' do
  let!(:user) { create_user }
  let!(:joined_contest) {
    create_contest(
      description: 'This is a referral contest',
      prize: 'The prize is a new car',
      terms_and_conditions: 'These are terms and conditions',
      image: '/assets/profile.jpg'
    )
  }
  let!(:referred_contest) { create_contest }

  before do
    create_virtual_currency
    @event_type = create_event_type(name: Plink::EventTypeRecord.email_capture_type)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
  end

  it 'tracks the referal for a contest', :vcr, js: true do
    visit contest_referral_path(user_id: user.id, affiliate_id: 1432, contest_id: referred_contest.id, source: 'contest_entry_post')

    page.current_path.should == contests_path
    page.should have_content 'This is a referral contest'.upcase

    within '.contests' do
      click_on 'Join'
    end

    within '.sign-in-modal' do
      page.find('img[alt="Register with Email"]').click

      fill_in 'First Name', with: 'Frud'
      fill_in 'Email', with: 'furd@example.com'
      fill_in 'Password', with: 'pass1word'
      fill_in 'Verify Password', with: 'pass1word'

      click_on 'Start Earning Rewards'
    end

    within ".welcome-text" do
      page.should have_content 'Welcome, Frud!'
    end

    page.should have_content 'This is a referral contest'.upcase

    tracked_event = Plink::EventRecord.order('eventID desc').first

    tracked_event.event_type_id.should == @event_type.id
    tracked_event.affiliate_id.should == 1432
    tracked_event.sub_id.should == "contest_entry_post"
    tracked_event.sub_id_two.should == "contest_id_#{joined_contest.id}"
    tracked_event.sub_id_three.should == "contest_id_#{referred_contest.id}"
    tracked_event.is_active.should be_true
    tracked_event.created_at.should be
  end
end

