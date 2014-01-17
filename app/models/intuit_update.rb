class IntuitUpdate
  def initialize(user_id)
    @user_id = user_id
  end

  def select_account!(staged_account, account_type)
    account_record = Plink::UsersInstitutionAccountRecord.create(staged_account.values_for_final_account)

    if account_type.present?
      formatted_account_type = text_for_account_type(account_type)

      staged_account.update_attributes(account_type: formatted_account_type)
      account_record.update_attributes(account_type: formatted_account_type)
      request = Intuit::Request.new(@user_id).update_account_type(account_record.account_id, formatted_account_type)
    end

    account_record
  end

private

  def text_for_account_type(account_type)
    case account_type
    when 'credit'
      'CREDITCARD'
    when 'debit'
      'CHECKING'
    end
  end
end
