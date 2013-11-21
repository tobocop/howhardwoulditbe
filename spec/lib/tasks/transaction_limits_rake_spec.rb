require 'spec_helper'

describe 'transaction_limits:enforce_staples_limit', skip_in_build: true do
  include_context 'rake'

  let!(:no_previous_transaction_user) { create_user(email: 'ishouldearn@plink.com') }
  let!(:nine_previous_transactions_one_current_transaction_user) { create_user(email: 'ishouldearnonce@plink.com') }
  let!(:nine_previous_transactions_two_current_transaction_user) { create_user(email: 'ishouldearnonlyonce@plink.com') }
  let!(:ten_previous_transactions_two_current_transaction_user) { create_user(email: 'ishouldnotearn@plink.com') }

  before do
    staples = create_advertiser(advertiser_name: 'Staples')

    9.times { create_intuit_transaction(user_id: nine_previous_transactions_one_current_transaction_user.id, advertiser_id: staples.id) }
    9.times { create_intuit_transaction(user_id: nine_previous_transactions_two_current_transaction_user.id, advertiser_id: staples.id) }
    10.times { create_intuit_transaction(user_id: ten_previous_transactions_two_current_transaction_user.id, advertiser_id: staples.id) }

    create_intuit_transaction_staging(is_qualified: true, user_id: no_previous_transaction_user.id, advertiser_id: staples.id)
    create_intuit_transaction_staging(is_qualified: true, user_id: nine_previous_transactions_one_current_transaction_user.id, advertiser_id: staples.id)
    2.times { create_intuit_transaction_staging(is_qualified: true, user_id: nine_previous_transactions_two_current_transaction_user.id, advertiser_id: staples.id) }
    2.times { create_intuit_transaction_staging(is_qualified: true, user_id: ten_previous_transactions_two_current_transaction_user.id, advertiser_id: staples.id) }

    [no_previous_transaction_user,
      nine_previous_transactions_one_current_transaction_user,
      nine_previous_transactions_two_current_transaction_user,
      ten_previous_transactions_two_current_transaction_user
    ].each do |user|
      create_intuit_transaction(user_id: user.id, advertiser_id: staples.id, post_date: 31.days.ago)
    end

    business_rule_reason = Plink::BusinessRuleReasonRecord.new(
      name: 'OVER STAPLES TRANSACTION LIMIT',
      description: 'The transaction is not qualified because the user has already had 10 staples transactions within 30 days',
      is_active: true
    )
    business_rule_reason.id = 500
    business_rule_reason.save!
  end

  it 'does not allow users to earn on more then 10 staples transactions' do
    subject.invoke

    Plink::IntuitTransactionStagingRecord.where(is_qualified: true, user_id: no_previous_transaction_user.id).length.should == 1

    Plink::IntuitTransactionStagingRecord.where(is_qualified: true, user_id: nine_previous_transactions_one_current_transaction_user.id).length.should == 1

    Plink::IntuitTransactionStagingRecord.where(is_qualified: true, user_id: nine_previous_transactions_two_current_transaction_user.id).length.should == 1
    Plink::IntuitTransactionStagingRecord.where(is_qualified: false, user_id: nine_previous_transactions_two_current_transaction_user.id).length.should == 1

    Plink::IntuitTransactionStagingRecord.where(is_qualified: true, user_id: ten_previous_transactions_two_current_transaction_user.id).length.should == 0
    Plink::IntuitTransactionStagingRecord.where(is_qualified: false, user_id: ten_previous_transactions_two_current_transaction_user.id).length.should == 2
  end

  it 'updates transactions that should not earn with the correct business rule reason' do
    subject.invoke

    Plink::IntuitTransactionStagingRecord.where(business_rule_reason_id: 500).length.should == 3
  end
end

describe 'transaction_limits:create_transaction_limit_businss_rule_reason', skip_in_build: true do
  include_context 'rake'
  it 'creates the business rule reason for transactions that exceed the maximum count' do
    subject.invoke

    business_rule_reason = Plink::BusinessRuleReasonRecord.find(500)
    business_rule_reason.name.should == 'OVER STAPLES TRANSACTION LIMIT'
    business_rule_reason.description.should == 'The transaction is not qualified because the user has already had 10 staples transactions within 30 days'
    business_rule_reason.is_active.should be_true
  end
end
