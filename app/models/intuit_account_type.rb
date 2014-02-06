module IntuitAccountType
  module_function

  def AccountType(account_type)
    case account_type.to_s
    when /credit/i
      'CREDITCARD'
    when /checking/i, /debit/i
      'CHECKING'
    end
  end
end
