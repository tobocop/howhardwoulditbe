module Plink
  class IntuitAccountService

    def find_by_user_id(user_id)
      account_record = ActiveIntuitAccountRecord.where(user_id: user_id).order("#{Plink::ActiveIntuitAccountRecord.table_name}.uia_id DESC").first
      create_intuit_account(account_record) if account_record
    end

    def user_has_account?(user_id)
      Plink::ActiveIntuitAccountRecord.user_has_account?(user_id)
    end

    private

    def create_intuit_account(account_record)
      Plink::IntuitAccount.new(
        account_name: account_record.account_name,
        account_number_last_four: account_record.account_number_last_four,
        bank_name: account_record.bank_name,
        requires_reverification: account_record.requires_reverification?,
        reverification_id: account_record.incomplete_reverification_id,
        users_institution_id: account_record.users_institution_id
      )
    end
  end
end
