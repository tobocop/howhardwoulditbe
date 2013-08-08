require 'spec_helper'

describe Plink::RewardRedemptionService do

  subject { Plink::RewardRedemptionService }
  let(:valid_params) {{reward_amount_id: 3, user_balance: 41, user_id: 3, first_name: 'John', email: 'john@example.com'}}

  describe 'redeem' do
    it 'returns false if the user does not have enough to redeem' do
      Plink::RewardAmountRecord.stub(:find).and_return (stub(dollar_award_amount:5, reward_id: 3))

      subject.new(valid_params.merge(user_balance:4.5)).redeem.should be_false
    end

    it 'returns false if the redemption amount is more than $10' do
      Plink::RewardAmountRecord.stub(:find).and_return (stub(dollar_award_amount:10.01, reward_id: 3))

      subject.new(valid_params.merge(user_balance:100)).redeem.should be_false
    end

    it 'inserts the redemption record as pending' do
      Plink::RewardAmountRecord.stub(:find).and_return (stub(dollar_award_amount:5, reward_id: 6))
      Plink::RewardRecord.stub(:find).and_return (stub(id: 6, is_tango:false))

      Plink::RedemptionRecord.should_receive(:create).with(
        dollar_award_amount: 5,
        reward_id: 6,
        user_id: 3,
        is_pending: true
      ).and_return(true)

      subject.new(valid_params).redeem
    end

    context 'via tango' do
      before do
        fake_reward_amount = mock(:fake_reward_amount, dollar_award_amount: 5, reward_id: 2)
        Plink::RewardAmountRecord.stub(:find).and_return(fake_reward_amount)

        fake_reward = mock(:fake_reward, is_tango: true, id: 2, award_code: 'code123', name: 'walmart gift card')
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
        ).and_return { stub(successful?: true) }

        Plink::RedemptionRecord.stub(:create)

        subject.new(valid_params).redeem
      end

      it 'creates the redemption record as sent' do
        Tango::CardService.any_instance.stub(:purchase) { stub(successful?: true) }

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
