module Plink
  class IntuitAccountService

    def find_by_user_id(user_id)
      account_record = ActiveIntuitAccountRecord.where(user_id: user_id).order("#{Plink::ActiveIntuitAccountRecord.table_name}.uia_id DESC").first
      create_active_intuit_account(account_record) if account_record
    end

    def user_has_account?(user_id)
      Plink::ActiveIntuitAccountRecord.user_has_account?(user_id)
    end

    private

    def create_active_intuit_account(active_intuit_account_record)
      Plink::ActiveIntuitAccount.new(
        bank_name: active_intuit_account_record.bank_name,
        account_name: active_intuit_account_record.account_name,
        account_number_last_four: active_intuit_account_record.account_number_last_four
      )
    end
  end
end