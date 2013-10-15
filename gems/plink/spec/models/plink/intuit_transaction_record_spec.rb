require 'spec_helper'

describe Plink::IntuitTransactionRecord do

  it { should allow_mass_assignment_of(:account_id) }
  it { should allow_mass_assignment_of(:advertiser_id) }
  it { should allow_mass_assignment_of(:amount) }
  it { should allow_mass_assignment_of(:hashed_value) }
  it { should allow_mass_assignment_of(:intuit_transaction_id) }
  it { should allow_mass_assignment_of(:job_id) }
  it { should allow_mass_assignment_of(:offer_id) }
  it { should allow_mass_assignment_of(:offers_virtual_currency_id) }
  it { should allow_mass_assignment_of(:payee_name) }
  it { should allow_mass_assignment_of(:post_date) }
  it { should allow_mass_assignment_of(:search_pattern_id) }
  it { should allow_mass_assignment_of(:task_id) }
  it { should allow_mass_assignment_of(:tier_id) }
  it { should allow_mass_assignment_of(:uia_account_id) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }
  it { should allow_mass_assignment_of(:users_virtual_currency_id) }
  it { should allow_mass_assignment_of(:virtual_currency_id) }

  let(:valid_params) {
    {
      account_id: 1,
      advertiser_id: 1827,
      amount: -123.02,
      hashed_value: 'aoishd',
      intuit_transaction_id: 8123467,
      job_id: 123,
      offer_id: 3,
      offers_virtual_currency_id: 1,
      payee_name: 'taco derp',
      post_date: 3.days.ago,
      search_pattern_id: 1,
      task_id: 1,
      tier_id: 1,
      uia_account_id: 1,
      user_id: 1,
      users_institution_id: 1,
      users_virtual_currency_id: 1,
      virtual_currency_id: 1
    }
  }

  it 'can be persisted' do
    Plink::IntuitTransactionRecord.create(valid_params).should be_persisted
  end
end