require 'spec_helper'

describe Plink::RewardRedemptionService do

  subject { Plink::RewardRedemptionService }
  let(:user) { new_user(id: 3, first_name: 'John', email: 'john@example.com') }
  let(:valid_params) { {reward_amount_id: 3, user_balance: 41, user_id: user.id, first_name: user.first_name, email: user.email } }

  describe '#redeem' do
    it 'returns false if the user does not have enough to redeem' do
      Plink::RewardAmountRecord.stub(:find).and_return (double(dollar_award_amount: 5, reward_id: 3))

      subject.new(valid_params.merge(user_balance: 4.5)).redeem.should be_false
    end

    it 'returns false if the redemption amount is more than $10' do
      Plink::RewardAmountRecord.stub(:find).and_return (double(dollar_award_amount: 10.01, reward_id: 3))

      subject.new(valid_params.merge(user_balance: 100)).redeem.should be_false
    end

    context 'pending' do
      before :each do
        fake_reward_amount = double(:fake_reward_amount, dollar_award_amount: 5, reward_id: 2)
        Plink::RewardAmountRecord.stub(:find).and_return(fake_reward_amount)
      end

      describe 'if the user has less than 2 qualifying rewards' do
        it 'creates the redemption record as pending if the reward is not tango' do
          fake_reward = double(:fake_reward, is_tango: false, id: 2, award_code: 'code123', name: 'walmart gift card')
          Plink::RewardRecord.stub(:find).with(2).and_return(fake_reward)

          Plink::RedemptionRecord.should_receive(:create).with(
            dollar_award_amount: 5,
            reward_id: 2,
            user_id: 3,
            is_pending: true
          )

          Plink::UserRecord.stub(:find).with(3).and_return(user)

          subject.new(valid_params).redeem
        end

        it 'creates the redemption record as pending if the reward is tango' do
          fake_reward = double(:fake_reward, is_tango: true, id: 2, award_code: 'code123', name: 'walmart gift card')
          Plink::RewardRecord.stub(:find).with(2).and_return(fake_reward)

          Plink::RedemptionRecord.should_receive(:create).with(
            dollar_award_amount: 5,
            reward_id: 2,
            user_id: 3,
            is_pending: true
          )

          Plink::UserRecord.stub(:find).with(3).and_return(user)

          subject.new(valid_params).redeem
        end

      end

      describe 'if the user has more then 2 qualifying rewards' do
        before :each do
          create_qualifying_award(user_id: valid_params[:user_id])
          create_qualifying_award(user_id: valid_params[:user_id])
        end

        it 'creates the redemption record as pending if the reward is not tango' do
          fake_reward = double(:fake_reward, is_tango: false, id: 2, award_code: 'code123', name: 'walmart gift card')
          Plink::RewardRecord.stub(:find).with(2).and_return(fake_reward)

          Plink::UserRecord.stub(:find).with(3).and_return(user)

          Plink::RedemptionRecord.should_receive(:create).with(
            dollar_award_amount: 5,
            reward_id: 2,
            user_id: 3,
            is_pending: true
          )

          subject.new(valid_params).redeem
        end
      end
    end

    context 'for users who have successful, current redemptions' do

      let!(:reward) {
        create_reward(
          award_code: 'amazonia-card',
          name: 'amazonia',
          is_tango: true,
          description: 'howl at the moon',
          logo_url: '/assets/test/amazon.png'
        )
      }

      let!(:reward_amount) {
        create_reward_amount(
          reward_id: reward.id,
          dollar_award_amount: 10,
          is_active: true
        )
      }

      let!(:user_with_previous_award) {
        user = create_user(email: 'pinhead@example.com', first_name: 'Zippy', hold_redemptions: false)
        create_qualifying_award(user_id: user.id)
        create_qualifying_award(user_id: user.id)
        create_redemption(user_id: user.id, is_pending: false, sent_on: 1.hour.ago)
        create_tango_tracking(user_id: user.id, card_value: 91, sent_to_tango_on: 1.hour.ago, response_from_tango_on: 1.hour.ago)
        user
      }

      let!(:reward_params) {
        {
          reward_amount_id: reward_amount.id,
          user_balance: 2000,
          user_id: user_with_previous_award.id,
          first_name: 'Zippy',
          email: user_with_previous_award.email
        }
      }

      describe 'if the user is not over the daily limit in redemptions' do

        it 'creates the redemption record' do
          Tango::CardService.any_instance.stub(:purchase) { double(successful?: true) }

          Plink::TangoRedemptionService.should_receive(:new).with(
            award_code: reward.award_code,
            reward_name: reward.name,
            dollar_award_amount: reward_amount.dollar_award_amount,
            reward_id: reward.id,
            user_id: user_with_previous_award.id,
            first_name: user_with_previous_award.first_name,
            email: user_with_previous_award.email
          ).and_call_original

          subject.new(reward_params).redeem

        end
      end

      describe 'if the user has over the daily limit in redemptions' do

         it 'creates the redemption record as pending' do
           create_tango_tracking(user_id: user_with_previous_award.id, card_value: 10, sent_to_tango_on: 1.hour.ago, response_from_tango_on: 1.hour.ago)
           create_redemption(user_id: user_with_previous_award.id, is_pending: false)

           Tango::CardService.any_instance.stub(:purchase) { double(successful?: true) }

           Plink::PendingRedemptionService.should_receive(:new).with(
             dollar_award_amount: reward_amount.dollar_award_amount,
             reward_id: reward.id,
             user_id: user_with_previous_award.id
           ).and_call_original

           subject.new(reward_params).redeem

        end

      end
    end

    context 'via tango' do
      before :each do
        create_qualifying_award(user_id: valid_params[:user_id])
        create_qualifying_award(user_id: valid_params[:user_id])

        fake_reward_amount = double(:fake_reward_amount, dollar_award_amount: 5, reward_id: 2)
        Plink::RewardAmountRecord.stub(:find).and_return(fake_reward_amount)

        fake_reward = double(:fake_reward, is_tango: true, id: 2, award_code: 'code123', name: 'walmart gift card')
        Plink::RewardRecord.stub(:find).with(2).and_return(fake_reward)
      end

      it 'tells tango to redeem the award' do
        Tango::CardService.any_instance.should_receive(:purchase).with(
          card_sku: 'code123',
          card_value: 500,
          tango_sends_email: true,
          recipient_name: 'John',
          recipient_email: 'john@example.com',
          gift_message: "Here's your walmart gift card",
          gift_from: 'Plink'
        ).and_return { double(successful?: true) }

        Plink::RedemptionRecord.stub(:create)

        subject.new(valid_params).redeem
      end

      it 'creates the redemption record as sent' do
        Tango::CardService.any_instance.stub(:purchase) { double(successful?: true) }

        Plink::RedemptionRecord.should_receive(:create).with(
          dollar_award_amount: 5,
          reward_id: 2,
          user_id: 3,
          is_pending: false,
          sent_on: anything
        )

        subject.new(valid_params).redeem
      end

    end
  end
end
