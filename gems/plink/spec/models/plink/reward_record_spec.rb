require 'spec_helper'

describe Plink::RewardRecord do

  let (:valid_params) {
    {
      award_code: 'walmart-gift-card',
      name: 'wally world',
      is_active: true
    }
  }

  subject {Plink::RewardRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::RewardRecord.create(valid_params).should be_persisted
  end

  describe 'live' do

    before do
      create_reward(name:'do not find me', is_active: false)
      @expected = create_reward(name:'find me', is_active: true)
    end

    it 'returns active rewards' do
      rewards = Plink::RewardRecord.live
      rewards.size.should == 1
      rewards.should == [@expected]
    end

  end

  describe 'live_amounts' do

    before do
      subject.save!

      @active_reward_amount = create_reward_amount(reward_id: subject.id, is_active: true)
      @inactive_reward_amount = create_reward_amount(reward_id: subject.id, is_active: false)
    end

    it 'returns only amount that are active' do
      subject.live_amounts.should == [@active_reward_amount]
    end
  end
end