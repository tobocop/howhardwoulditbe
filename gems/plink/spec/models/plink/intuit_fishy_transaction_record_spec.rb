require 'spec_helper'

describe Plink::IntuitFishyTransactionRecord do

  it { should allow_mass_assignment_of(:account_id) }
  it { should allow_mass_assignment_of(:advertiser_id) }
  it { should allow_mass_assignment_of(:amount) }
  it { should allow_mass_assignment_of(:business_rule_reason_id) }
  it { should allow_mass_assignment_of(:hashed_value) }
  it { should allow_mass_assignment_of(:intuit_transaction_id) }
  it { should allow_mass_assignment_of(:is_fishy) }
  it { should allow_mass_assignment_of(:is_intuit_pending) }
  it { should allow_mass_assignment_of(:is_in_wallet) }
  it { should allow_mass_assignment_of(:is_nonqualified) }
  it { should allow_mass_assignment_of(:is_over_minimum_amount) }
  it { should allow_mass_assignment_of(:is_qualified) }
  it { should allow_mass_assignment_of(:is_return) }
  it { should allow_mass_assignment_of(:is_search_pattern_pending) }
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
      business_rule_reason_id: 1,
      hashed_value: 'aoishd',
      intuit_transaction_id: 8123467,
      is_fishy: true,
      is_intuit_pending: true,
      is_in_wallet: true,
      is_nonqualified: false,
      is_over_minimum_amount: true,
      is_qualified: true,
      is_return: true,
      is_search_pattern_pending: false,
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
    Plink::IntuitFishyTransactionRecord.create(valid_params).should be_persisted
  end

  context 'scopes' do
    describe '.active_by_user_id' do
      let!(:intuit_fishy_transaction_record) { create_intuit_fishy_transaction(user_id: 34, is_active: true) }
      let(:active_by_user_id) { Plink::IntuitFishyTransactionRecord.active_by_user_id(34) }

      before do
        create_intuit_fishy_transaction(user_id: 24, is_active: true)
      end

      it 'returns records that are active where the user_id matches' do
        active_by_user_id.length.should == 1
        active_by_user_id.first.id.should == intuit_fishy_transaction_record.id
      end

      it 'does not return inactive records' do
        intuit_fishy_transaction_record.update_attribute('is_active', false)

        active_by_user_id.length.should == 0
      end

      it 'does not return records where the user_id doesn\'t match' do
        intuit_fishy_transaction_record.update_attribute('user_id', 198367)

        active_by_user_id.length.should == 0
      end
    end
  end
end
