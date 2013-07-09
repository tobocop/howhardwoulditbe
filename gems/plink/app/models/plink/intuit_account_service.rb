module Plink
  class IntuitAccountService
    def user_has_account?(user_id)
      Plink::ActiveIntuitAccountRecord.user_has_account?(user_id)
    end
  end
end