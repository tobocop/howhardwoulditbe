class InstitutionAccountsPresenter
  def initialize(intuit_accounts_response)
    @accounts = intuit_accounts_response
  end

  def banking_and_credit
    valid_accounts = @accounts.select do |account_type|
      account_type == :banking_account || account_type == :credit_account
    end

    account_presenters = []
    valid_accounts.each_pair do |account_type, account_list|
      account_list.each do |account|
        account_presenters.push(InstitutionAccountPresenter.new(account))
      end
    end

    account_presenters
  end
end
