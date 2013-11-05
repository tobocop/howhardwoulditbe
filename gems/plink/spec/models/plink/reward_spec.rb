require 'spec_helper'

describe Plink::Reward do
  let(:reward_amount) { new_reward_amount }
  let(:valid_params) {
    {
      id: 100,
      name: 'terget',
      description: 'ermagherd',
      is_redeemable: true,
      logo_url: 'http://example.com/logo',
      terms: 'onerous'
    }
  }

  subject { Plink::Reward.new(valid_params, [reward_amount]) }

  it 'uses info from an reward record to populate all fields' do
    subject.amounts.size.should == 1
    amount = subject.amounts.first
    amount.class.should == Plink::RewardAmount

    subject.id.should == 100
    subject.name.should == 'terget'
    subject.description.should == 'ermagherd'
    subject.logo_url.should == 'http://example.com/logo'
    subject.terms.should == 'onerous'
  end

  describe '#deliver_by_email?' do

    let(:snail_mail_gc) { Plink::Reward.new(valid_params.merge({ name: 'Subway Gift Card' }), [reward_amount]) }
    let(:email_gc) { Plink::Reward.new(valid_params, [reward_amount]) }

    it 'returns true if the card is delivered via email' do
      email_gc.deliver_by_email?.should be_true
    end

    it 'returns false if the card is delivered via the postal service' do
      snail_mail_gc.deliver_by_email?.should be_false
    end
  end
end
