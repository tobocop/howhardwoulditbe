require 'spec_helper'

describe Plink::ReferralService do
  describe '#award_referral' do
    let(:free_award_service) { double(Plink::FreeAwardService, award_referral_bonus: true) }

    before do
      Plink::FreeAwardService.stub(:new).and_return(free_award_service)
      Plink::WalletItemUnlockingService.stub(:unlock_referral_slot)
      Plink::ReferralConversionRecord.stub(:create)
    end

    it 'it converts the passed in object to an int' do
      user_id = double(to_i: 0)
      user_id.should_receive(:to_i)

      Plink::ReferralService.award_referral(user_id, 2)
    end

    context 'when the referring_user_id is 0' do
      it 'does not create a free award record' do
        Plink::FreeAwardService.should_not_receive(:new)

        Plink::ReferralService.award_referral(0, 2)
      end
    end

    context 'when the referring_user_id is not 0' do
      it 'creates a free award of 100 Plink Points' do
        Plink::FreeAwardService.should_receive(:new).with(1).and_return(free_award_service)
        free_award_service.should_receive(:award_referral_bonus).with(34)

        Plink::ReferralService.award_referral(34, 2)
      end

      it 'unlocks a slot for the user' do
        Plink::WalletItemUnlockingService.should_receive(:unlock_referral_slot).with(34)

        Plink::ReferralService.award_referral(34, 2)
      end

      it 'creates a referral conversion' do
        Plink::ReferralConversionRecord.should_receive(:create).with({
          referred_by: 34,
          created_user_id: 2
        })

        Plink::ReferralService.award_referral(34, 2)
      end
    end
  end
end
