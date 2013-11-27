module Intuit
  class AccountsPresenter
    def initialize(intuit_accounts_response)
      @accounts = intuit_accounts_response
    end

    def accounts
      account_presenters = []

      @accounts.each_pair do |account_type, account_list|
        account_list.each do |account|
          account_presenters.push(Intuit::AccountPresenter.new(account, account_type))
        end
      end

      account_presenters
    end
  end
end
