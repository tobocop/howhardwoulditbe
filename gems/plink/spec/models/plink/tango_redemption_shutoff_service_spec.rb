require 'spec_helper'

describe Plink::TangoRedemptionShutoffService do
  let!(:tango_reward) { create_reward(is_tango: true, name: 'Tango Card') }
  let!(:non_tango_reward) { create_reward }
  let(:shutoff_service) { Plink::TangoRedemptionShutoffService }

  describe '.halt_redemptions' do
    it 'marks all Tango loot as non-redeemable' do
      shutoff_service.halt_redemptions

      tango_reward.reload.is_redeemable.should be_false
      tango_reward.is_active.should be_true
    end

    it 'does not mark Tango loot as non-redeemable' do
      shutoff_service.halt_redemptions

      non_tango_reward.reload.is_redeemable.should be_true
      non_tango_reward.is_active.should be_true
    end
  end

  describe '.resume_redemptions' do
    before { tango_reward.update_attributes(is_redeemable: false) }
    it 'marks all Tango rewards as redeemable' do

      shutoff_service.resume_redemptions

      tango_reward.reload.is_redeemable.should be_true
      tango_reward.is_active.should be_true
    end

    it 'does not care if a reward is active or not' do
      tango_reward.update_attributes(is_redeemable: false, is_active: false)

      shutoff_service.resume_redemptions

      tango_reward.reload.is_redeemable.should be_true
      tango_reward.is_active.should be_false
    end
  end
end
