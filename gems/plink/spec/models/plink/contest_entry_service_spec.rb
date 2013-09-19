require 'spec_helper'

describe Plink::ContestEntryService do
  let(:user) { create_user }
  let(:contest) { create_contest }

  describe '.enter' do
    it 'creates a contest entry record' do
      Plink::ContestEntryService.enter(contest.id, user.id, ['twitter', 'facebook'], {entry_source: 'entry_source'})

      Plink::EntryRecord.first.contest_id.should == contest.id
      Plink::EntryRecord.first.user_id.should == user.id
      Plink::EntryRecord.first.provider.should == 'twitter'
      Plink::EntryRecord.first.source.should == 'entry_source'

      Plink::EntryRecord.last.contest_id.should == contest.id
      Plink::EntryRecord.last.user_id.should == user.id
      Plink::EntryRecord.last.provider.should == 'facebook'
      Plink::EntryRecord.last.source.should == 'entry_source'
    end

    describe 'multipliers' do
      context 'for users with a linked card' do
        before do
          create_oauth_token(user_id: user.id)
          create_users_institution_account(user_id: user.id)
          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter', 'facebook'])
        end

        it 'gives a 5X multiplier' do
          entry = Plink::EntryRecord.last
          entry.multiplier.should == 5
          entry.computed_entries.should == 5
        end
      end

      context 'for users without a linked card' do
        before { Plink::ContestEntryService.enter(contest.id, user.id, ['twitter', 'facebook']) }

        it 'gives a 1X multiplier' do
          entry = Plink::EntryRecord.last
          entry.multiplier.should == 1
          entry.computed_entries.should == 1
        end
      end
    end

    describe 'referral entries' do
      context 'for a referring user with a linked card' do
        before do
          create_oauth_token(user_id: user.id)
          create_users_institution_account(user_id: user.id)
        end

        it 'returns 100 entries for two referred users who have linked a card' do
          user_2 = create_user(email: 'user_2@example.com')
          create_oauth_token(user_id: user_2.id)
          create_users_institution_account(user_id: user_2.id)

          user_3 = create_user(email: 'user_3@example.com')
          create_oauth_token(user_id: user_3.id)
          create_users_institution_account(user_id: user_3.id)

          create_referral(referred_by: user.id, created_user_id: user_2.id)
          create_referral(referred_by: user.id, created_user_id: user_3.id)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 100
          entry.computed_entries.should == 100 + 5
        end

        it 'returns no entries per referred users who has not linked a card' do
          create_referral(referred_by: user.id, created_user_id: 10)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 0
          entry.computed_entries.should == 5
        end
      end

      context 'for a referring user without a linked card' do
        it 'returns 20 referral entries for two referred users who have each linked a card' do
          user_2 = create_user(email: 'user_2@example.com')
          create_oauth_token(user_id: user_2.id)
          create_users_institution_account(user_id: user_2.id)

          user_3 = create_user(email: 'user_3@example.com')
          create_oauth_token(user_id: user_3.id)
          create_users_institution_account(user_id: user_3.id)

          create_referral(referred_by: user.id, created_user_id: user_2.id)
          create_referral(referred_by: user.id, created_user_id: user_3.id)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 20
          entry.computed_entries.should == 20 + 1
        end
        it 'returns no referral entries for referred users who have not linked a card' do
          create_referral(referred_by: user.id, created_user_id: 10)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 0
          entry.computed_entries.should == 1
        end
      end

      context 'does not use referrals' do
        let(:user_2) do
          user_2 = create_user(email: 'user_2@example.com')
          create_oauth_token(user_id: user_2.id)
          create_users_institution_account(user_id: user_2.id)
          user_2
        end

        it 'made before the contest period' do
          old_referral = create_referral(referred_by: user.id, created_user_id: user_2.id)
          old_referral.update_attribute(:created, 200.days.ago)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 0
          entry.computed_entries.should == 1
        end

        it 'made after the contest period' do
          future_referral = create_referral(referred_by: user.id, created_user_id: user_2.id)
          future_referral.update_attribute(:created, 200.days.from_now)

          Plink::ContestEntryService.enter(contest.id, user.id, ['twitter'])

          entry = Plink::EntryRecord.last
          entry.referral_entries.should == 0
          entry.computed_entries.should == 1
        end
      end
    end
  end

  describe '.exceeded_daily_submission_limit?' do
    it 'returns true if the user has entered once per social network already' do
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'twitter')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'facebook')

      Plink::ContestEntryService.exceeded_daily_submission_limit?(user).should be_true
    end

    it 'returns false if the user has not entered once per social network already' do
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'facebook')

      Plink::ContestEntryService.exceeded_daily_submission_limit?(user).should be_false
    end

    context 'tomorrow' do
      let!(:tomorrow) { Time.zone.now + 1.day }

      before do
        create_entry(contest_id: contest.id, user_id: user.id, provider: 'twitter')
        create_entry(contest_id: contest.id, user_id: user.id, provider: 'facebook')
        Time.zone.stub(:today).and_return(tomorrow)
      end

      it 'allows the user to enter again' do
        Plink::ContestEntryService.exceeded_daily_submission_limit?(user).should be_false
      end
    end
  end

  describe '.total_entries' do
    it 'returns the sum of computed_entries given a contest_id and a user_id' do
      Plink::EntryRecord.should_receive(:summed_computed_entries_by_contest_id_and_user_id)
        .with(1, 3) { 143 }

      Plink::ContestEntryService.total_entries(1, 3).should == 143
    end
  end

  describe '.total_entries_via_share' do
    subject(:service) { Plink::ContestEntryService }

    context 'for an unlinked user' do
      context 'for a single network' do
        it 'returns 1 if the user has not referred anyone' do
          service.total_entries_via_share(user.id, contest.id, false, 1).should == 1
        end

        context 'with a referral who has signed up' do
          let!(:user_2) { create_user(email: 'unique@example.com') }

          before do
            create_referral(referred_by: user.id, created_user_id: user_2.id)
          end

          it 'returns 1 if they did not link a card' do
            service.total_entries_via_share(user.id, contest.id, false, 1).should == 1
          end

          it 'returns 11 if they linked a card' do
            create_oauth_token(user_id: user_2.id)
            create_users_institution_account(user_id: user_2.id)

            service.total_entries_via_share(user.id, contest.id, false, 1).should == 11
          end
        end
      end
    end

    context 'for a linked user' do
      before do
        create_oauth_token(user_id: user.id)
        create_users_institution_account(user_id: user.id)
      end

      context 'for 3 networks' do
        it 'returns 15 if the user has not referred anyone' do
          service.total_entries_via_share(user.id, contest.id, true, 3).should == 15
        end

        context 'with a referral who has signed up' do
          let!(:user_2) { create_user(email: 'unique@example.com') }

          before do
            create_referral(referred_by: user.id, created_user_id: user_2.id)
          end

          it 'returns 15 if they did not link a card' do
            service.total_entries_via_share(user.id, contest.id, true, 3).should == 15
          end

          it 'returns 165 if they linked a card' do
            create_oauth_token(user_id: user_2.id)
            create_users_institution_account(user_id: user_2.id)


            service.total_entries_via_share(user.id, contest.id, true, 3).should == 165
          end
        end
      end
    end
  end

  describe '.user_multiplier' do
    it 'calls the intuit account service' do
      Plink::IntuitAccountService.any_instance.should_receive(:user_has_account?).with(user.id)

      Plink::ContestEntryService.user_multiplier(user.id)
    end

    it 'returns the UNLINKED_CARD_MULTIPLIER if it is called for a user without a linked card' do
      Plink::IntuitAccountService.any_instance.should_receive(:user_has_account?).with(user.id).and_return(false)

      multiplier = Plink::ContestEntryService::UNLINKED_CARD_MULTIPLIER

      Plink::ContestEntryService.user_multiplier(user.id).should == multiplier
    end

    it 'returns the LINKED_CARD_MULTIPLIER if it is called with a linked card' do
      multiplier = Plink::ContestEntryService::LINKED_CARD_MULTIPLIER

      Plink::ContestEntryService.user_multiplier(user.id, true).should == multiplier
    end
  end
end
