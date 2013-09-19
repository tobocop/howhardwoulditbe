require 'spec_helper'

describe Plink::ContestRecord do
  let(:valid_attributes) {
    {
      description: 'This is a great contest',
      image: '/assets/test_image_tbd.jpg',
      prize: 'The prize is a new car',
      start_time: 2.days.ago.to_date,
      end_time: 2.days.from_now.to_date,
      terms_and_conditions: 'There are a ton of terms and conditions'
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
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:terms_and_conditions) }

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

  it { should have_many(:entry_records) }

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
end
