require 'spec_helper'

describe Plink::TangoRedemptionShutoffService do

  let!(:tango_award) { create_reward(is_tango: true, name: 'Tango Card') }
  let!(:non_tango_award) { create_reward }
  let(:shutoff_service) { Plink::TangoRedemptionShutoffService }

  describe '.halt_redemptions' do
    it 'marks all Tango loot as inactive' do
      shutoff_service.halt_redemptions
      
      Plink::RewardRecord.where(lootID: tango_award.id).first.is_active.should be_false
      Plink::RewardRecord.where(lootID: non_tango_award.id).first.is_active.should be_true
    end
  end
end