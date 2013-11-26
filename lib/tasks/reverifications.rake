namespace :reverifications do
  desc 'Inserts pending reverifications based on what errors users have been receiving'
  task insert_reverification_notices: :environment do
    intuit_account_service = Plink::IntuitAccountService.new
    Plink::UserIntuitErrorRecord.errors_that_require_attention.each do |user_intuit_error|
      intuit_account = intuit_account_service.find_by_user_id(user_intuit_error.user_id)
      user_record = Plink::UserRecord.find_by_id(user_intuit_error.user_id)

      next if intuit_account.blank? || user_record.primary_virtual_currency != plink_points

      if intuit_account.users_institution_id == user_intuit_error.users_institution_id && intuit_account.active?
        Plink::UserReverificationRecord.create(
          user_id: user_intuit_error.user_id,
          users_institution_id: user_intuit_error.users_institution_id,
          users_intuit_error_id: user_intuit_error.id
        )
      end
    end
  end

private

  def plink_points
    Plink::VirtualCurrency.default
  end
end
