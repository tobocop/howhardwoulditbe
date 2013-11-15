require 'spec_helper'

describe Plink::UserEligibleForOfferAddBonusRecord do
  it { should allow_mass_assignment_of(:is_awarded) }
  it { should allow_mass_assignment_of(:offers_virtual_currency_id) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should belong_to(:user_record) }

  let(:valid_params) {
    {
      is_awarded: true,
      offers_virtual_currency_id: 4,
      user_id: 3
    }
  }

  it 'can be persisted' do
    Plink::UserEligibleForOfferAddBonusRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it 'is valid with a unique combination of user_id and offers_virtual_currency_id' do
      user_eligible_for_offer_add_bonus = Plink::UserEligibleForOfferAddBonusRecord.new(valid_params)
      user_eligible_for_offer_add_bonus.should be_valid
      user_eligible_for_offer_add_bonus.save

      Plink::UserEligibleForOfferAddBonusRecord.new(valid_params).should_not be_valid
    end
  end
end
