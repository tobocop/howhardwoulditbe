require 'spec_helper'

describe Plink::RewardRecord do

  let (:valid_params) {
    {
      award_code: 'walmart-gift-card',
      name: 'wally world',
      is_active: true,
      is_tango: false,
      description: 'good reward',
      logo_url: 'http://example.com/logo',
      display_order: 1
    }
  }

  subject {Plink::RewardRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::RewardRecord.create(valid_params).should be_persisted
  end

  context 'named scopes' do
    describe 'live' do
      let!(:second_reward) { create_reward(name:'find me', is_active: true, display_order: 2) }
      let!(:first_reward) { create_reward(name:'find me', is_active: true, display_order: 1) }
      let!(:inactive_reward) { create_reward(name:'do not find me', is_active: false) }

      it 'returns active rewards ordered by display order' do
        ordered_rewards = [first_reward, second_reward]

        rewards = Plink::RewardRecord.live
        rewards.size.should == 2
        rewards.should == ordered_rewards
        rewards.each do |reward|
          reward.should_not == inactive_reward
        end
      end
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
