require 'spec_helper'

describe Plink::EntryRecord do
  it { should allow_mass_assignment_of(:computed_entries) }
  it { should allow_mass_assignment_of(:contest_id) }
  it { should allow_mass_assignment_of(:multiplier) }
  it { should allow_mass_assignment_of(:provider) }
  it { should allow_mass_assignment_of(:referral_entries) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:source) }

  it { should ensure_inclusion_of(:provider).in_array(%w[twitter facebook admin]) }

  it { should belong_to(:contest_record) }
  it { should belong_to(:user_record) }

  describe 'validations' do
    it { should validate_presence_of(:computed_entries) }
    it { should validate_presence_of(:contest_id) }
    it { should validate_presence_of(:multiplier) }
    it { should validate_presence_of(:referral_entries) }
    it { should validate_presence_of(:user_id) }

    context '#one_entry_per_provider_per_day' do
      let(:contest) { create_contest }
      let!(:entry) { create_entry(user_id: 23, contest_id: contest.id,
        provider: 'twitter', multiplier: 1, computed_entries: 1) }

      it 'only allows one entry per provider per day' do
        second_entry = new_entry(
          user_id: 23,
          contest_id: contest.id,
          provider: 'twitter'
        )

        second_entry.should_not be_valid
      end

      it 'allows multiple admin entries per day' do
        admin_entry_1 = create_entry(user_id: 23, contest_id: contest.id,
        provider: 'admin', multiplier: 1, computed_entries: 1)

        admin_entry_2 = new_entry(user_id: 23, contest_id: contest.id,
        provider: 'admin', multiplier: 1, computed_entries: 10)

        admin_entry_2.should be_valid
      end
    end

    context '#contest_has_not_ended' do
      let(:user) { create_user }

      it 'does not allow entries after the contest has ended' do
        contest = create_contest(start_time: 5.days.ago.to_date, end_time: 1.day.ago.to_date)
        entry = new_entry(contest_id: contest.id, user_id: user.id)
        entry.should_not be_valid
        entry.should have(1).error_on(:contest_has_ended)
      end

      it 'allows entries before the contest has ended' do
        contest = create_contest(start_time: 5.days.ago.to_date, end_time: 1.day.from_now.to_date)
        entry = new_entry(contest_id: contest.id, user_id: user.id)
        entry.should be_valid
      end
    end

    context '#contest_has_started' do
      let(:user) { create_user }

      it 'does not allow entries before the contest has started' do
        contest = create_contest(start_time: 1.day.from_now.to_date, end_time: 5.days.from_now.to_date)
        entry = new_entry(contest_id: contest.id, user_id: user.id)
        entry.should_not be_valid
        entry.should have(1).error_on(:contest_has_not_started)
      end

      it 'allows entries after the contest has started' do
        contest = create_contest(start_time: 5.days.ago.to_date, end_time: 1.day.from_now.to_date)
        entry = new_entry(contest_id: contest.id, user_id: user.id)
        entry.should be_valid
      end
    end
  end

  describe 'named scopes' do
    describe '.entries_today_for_user' do
      let(:user) { create_user }
      let(:contest) { create_contest }
      let(:scope) { Plink::EntryRecord.entries_today_for_user(user.id) }

      it 'returns entries for today' do
        todays_entry = create_entry(user_id: user.id)

        scope.should include todays_entry
      end

      it 'does not return entries from yesterday' do
        yesterdays_entry = create_entry(user_id: user.id)
        yesterdays_entry.update_attribute(:created_at, Time.zone.today - 1.day)

        scope.should_not include yesterdays_entry
      end

      it 'does not return entries for another user' do
        other_users_entry = create_entry(user_id: user.id + 1)

        scope.should_not include other_users_entry
      end

    end

    describe '.entries_today_for_user_and_contest' do
      let(:user) { create_user }
      let(:contest) { create_contest }
      let(:scope) { Plink::EntryRecord.entries_today_for_user_and_contest(user.id, contest.id) }

      it 'returns entries for today' do
        todays_entry = create_entry(user_id: user.id, contest_id: contest.id)

        scope.should include todays_entry
      end

      it 'does not return entries from yesterday' do
        yesterdays_entry = create_entry(user_id: user.id, contest_id: contest.id)
        yesterdays_entry.update_attribute(:created_at, Time.zone.today - 1.day)

        scope.should_not include yesterdays_entry
      end

      it 'does not return entries for another user' do
        other_users_entry = create_entry(user_id: user.id + 1, contest_id: contest.id)

        scope.should_not include other_users_entry
      end

      it 'does not return entries for another contest' do
        other_contest_entry = create_entry(user_id: user.id, contest_id: contest.id + 1)

        scope.should_not include other_contest_entry
      end
    end

  end

  describe '.summed_computed_entries_by_contest_id_and_user_id' do
    let!(:entry) { create_entry(user_id: 1, contest_id: 3,
    provider: 'twitter', multiplier: 1, computed_entries: 101) }
    let!(:entry_2) { create_entry(user_id: 1, contest_id: 3,
    provider: 'facebook', multiplier: 1, computed_entries: 301) }

    it 'returns the sum of computed_entries' do
      Plink::EntryRecord.summed_computed_entries_by_contest_id_and_user_id(3,1).should == 402
    end
  end
end
