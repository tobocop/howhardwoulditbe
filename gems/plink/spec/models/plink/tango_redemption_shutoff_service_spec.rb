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
end
