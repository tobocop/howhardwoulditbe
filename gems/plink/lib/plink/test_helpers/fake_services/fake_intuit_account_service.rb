module Plink
  class FakeIntuitAccountService
    def initialize(accounts_by_id)
      @accounts_by_id = accounts_by_id
    end

    def find_by_user_id(user_id)
      @accounts_by_id[user_id]
    end

    def user_has_account?(user_id)
      !!@accounts_by_id[user_id]
    end
  end
end