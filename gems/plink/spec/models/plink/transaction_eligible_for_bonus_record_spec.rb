require 'spec_helper'

describe Plink::TransactionEligibleForBonusRecord do
  it { should allow_mass_assignment_of(:intuit_transaction_id) }
  it { should allow_mass_assignment_of(:offer_id) }
  it { should allow_mass_assignment_of(:offers_virtual_currency_id) }
  it { should allow_mass_assignment_of(:processed) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should belong_to(:user_record) }

  let(:valid_params) {
    {
      intuit_transaction_id: 1,
      offer_id: 39,
      offers_virtual_currency_id: 4,
      processed: true,
      user_id: 28
    }
  }

  it 'can be persisted' do
    Plink::TransactionEligibleForBonusRecord.create(valid_params).should be_persisted
  end
end
