require 'spec_helper'

describe Plink::ContestRecord do
  let(:valid_attributes) {
    {
      description: 'This is a great contest',
      image: '/assets/test_image_tbd.jpg',
      non_linked_image: '/assets/test_image_for_joe.jpg',
      prize: 'The prize is a new car',
      prize_description: 'The car is red',
      start_time: 2.days.ago.to_date,
      end_time: 2.days.from_now.to_date,
      terms_and_conditions: 'There are a ton of terms and conditions',
      finalized_at: nil,
      entry_post_title: 'enter today!',
      entry_post_body: 'enter the contest',
      winning_post_title: 'I won!',
      winning_post_body: 'i won the contest',
      entry_notification: 'enter this contest now'
    }
  }

  subject(:contest_record) { new_contest(valid_attributes) }

  it 'can be persisted' do
    contest_record.save.should be_true
  end

  context 'validations' do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:image) }
    it { should validate_presence_of(:prize) }
    it { should validate_presence_of(:prize_description) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:terms_and_conditions) }
    it { should validate_presence_of(:entry_post_title) }
    it { should validate_presence_of(:entry_post_body) }
    it { should validate_presence_of(:winning_post_title) }
    it { should validate_presence_of(:winning_post_body) }
    it { should validate_presence_of(:entry_notification) }

    it 'is invalid if it starts between any another contests start and end times' do
      create_contest( start_time: 3.days.ago.to_date, end_time: 3.days.from_now.to_date )

      contest_record.should_not be_valid
      contest_record.should have(1).error_on(:start_time_overlaps_existing_range)
    end

    it 'is invalid if it ends between any another contests start and end times' do
      create_contest( start_time: 1.day.ago.to_date, end_time: 3.days.from_now.to_date )

      contest_record.should_not be_valid
      contest_record.should have(1).error_on(:end_time_overlaps_existing_range)
    end

    it 'is invalid if the end_time is less than the start_time' do
      contest = new_contest( start_time: 1.day.from_now.to_date, end_time: 3.days.ago.to_date )
      contest.should_not be_valid
      contest.should have(1).error_on(:end_time_less_than_start_time)
    end

    it 'is valid if the start_time and end_time are updated to be within its own range' do
      contest_record.save
      contest_record.update_attributes(start_time: 1.day.ago.to_date)
      contest_record.should be_valid
    end
  end

  it { should accept_nested_attributes_for(:contest_emails) }
  it { should accept_nested_attributes_for(:contest_prize_levels) }

  it { should allow_mass_assignment_of(:description) }
  it { should allow_mass_assignment_of(:end_time) }
  it { should allow_mass_assignment_of(:entry_method) }
  it { should allow_mass_assignment_of(:finalized_at) }
  it { should allow_mass_assignment_of(:image) }
  it { should allow_mass_assignment_of(:non_linked_image) }
  it { should allow_mass_assignment_of(:prize) }
  it { should allow_mass_assignment_of(:prize_description) }
  it { should allow_mass_assignment_of(:start_time) }
  it { should allow_mass_assignment_of(:terms_and_conditions) }
  it { should allow_mass_assignment_of(:disclaimer_text) }
  it { should allow_mass_assignment_of(:entry_post_title) }
  it { should allow_mass_assignment_of(:entry_post_body) }
  it { should allow_mass_assignment_of(:winning_post_title) }
  it { should allow_mass_assignment_of(:winning_post_body) }
  it { should allow_mass_assignment_of(:interstitial_body_text) }
  it { should allow_mass_assignment_of(:interstitial_bold_text) }
  it { should allow_mass_assignment_of(:interstitial_reg_link) }
  it { should allow_mass_assignment_of(:interstitial_share_button) }
  it { should allow_mass_assignment_of(:interstitial_title) }
  it { should allow_mass_assignment_of(:entry_notification) }
  it { should allow_mass_assignment_of(:contest_emails_attributes) }
  it { should allow_mass_assignment_of(:contest_prize_levels_attributes) }

  it { should have_many(:entry_records) }
  it { should have_many(:contest_prize_levels) }
  it { should have_many(:contest_winners) }
  it { should have_one(:contest_emails) }

  context 'named scopes' do
    describe '.other_contests_within_time' do
      let!(:expected_contest) { create_contest(valid_attributes) }

      before do
        create_contest(start_time: 10.days.ago.to_date, end_time: 5.days.ago.to_date)
        create_contest(start_time: 5.days.from_now.to_date, end_time: 10.days.from_now.to_date)
      end

      it 'returns contests that dont match the given id and start and end within the given time' do
        contests = Plink::ContestRecord.other_contests_within_time(0, Time.zone.now)
        contests.should == [expected_contest]

        contests = Plink::ContestRecord.other_contests_within_time(expected_contest.id, Time.zone.now)
        contests.should == []
      end
    end
  end

  describe '.current' do
    it 'returns nil if there is no contest' do
      Plink::ContestRecord.current.should be_nil
    end

    it 'does not return past contests' do
      past_contest = create_contest(start_time: 1000.days.ago, end_time: 990.days.ago)

      Plink::ContestRecord.current.should_not == past_contest
    end

    it 'does not return future contests' do
      future_contest = create_contest(start_time: 1000.days.from_now, end_time: 1010.days.from_now)

      Plink::ContestRecord.current.should_not == future_contest
    end

    it 'returns a contest if there is one going on right now' do
      contest = create_contest

      Plink::ContestRecord.current.should == contest
    end
  end

  describe '#ended?' do
    it 'returns true if the end time is before now' do
      contest = new_contest(end_time: 1.day.ago.to_date)
      contest.ended?.should be_true
    end

    it 'returns false if the end time is after now' do
      contest = new_contest(end_time: 1.day.from_now.to_date)
      contest.ended?.should be_false
    end
  end

  describe '#started?' do
    it 'returns true if the start time is before now' do
      contest = new_contest(start_time: 1.day.ago.to_date)
      contest.started?.should be_true
    end

    it 'returns false if the start time is after now' do
      contest = new_contest(start_time: 1.day.from_now.to_date)
      contest.started?.should be_false
    end
  end

  describe '#finalized?' do
    it 'returns true if the results of a contest have been accepted and prizes distributed' do
      contest = new_contest(finalized_at: 1.hour.ago)
      contest.finalized?.should be_true
    end

    it 'returns false if the results of a contest have not been accepted' do
      contest = new_contest
      contest.finalized?.should be_false
    end

    it 'returns false if finalized is NULL' do
      contest = new_contest(finalized_at: nil)
      contest.finalized?.should be_false
    end
  end

  describe '.last_completed' do
    let!(:contest) { create_contest }

    it 'returns nil if there is no previous finalized contest' do
      Plink::ContestRecord.last_completed.should be_nil
    end

    it 'returns a contest if there is a last finalized contest' do
      contest.update_attributes(end_time: 20.minutes.ago, finalized_at: nil)

      Plink::ContestRecord.last_completed.should == contest
    end
  end

  describe '.last_finalized' do
    let!(:contest) { create_contest }

    it 'returns nil if there is no previous finalized contest' do
      Plink::ContestRecord.last_finalized.should be_nil
    end

    it 'returns a contest if there is a last finalized contest' do
      contest.update_attributes(end_time: 20.minutes.ago, finalized_at: Time.zone.now)
      older_contest = create_contest(start_time: 21.years.ago, end_time: 20.years.ago, finalized_at: 2.years.ago)

      Plink::ContestRecord.last_finalized.should == contest
      Plink::ContestRecord.last_finalized.should_not == older_contest
    end
  end
end
