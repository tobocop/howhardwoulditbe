namespace :transaction_limits do
  desc 'One-time task to test staples limit stored procedure'
  task enforce_staples_limit: :environment do
    ActiveRecord::Base.connection.execute('EXEC prc_enforce_transaction_limits')
  end

  desc 'One-time task to insert the staples over the limit business rule reason'
  task create_transaction_limit_businss_rule_reason: :environment do
    business_rule_reason = Plink::BusinessRuleReasonRecord.new(
      name: 'OVER STAPLES TRANSACTION LIMIT',
      description: 'The transaction is not qualified because the user has already had 10 staples transactions within 30 days',
      is_active: true
    )

    business_rule_reason.id = 500
    business_rule_reason.save!
  end
end
