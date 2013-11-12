module Plink
  class WalletQueryService
    attr_reader :relation

    def initialize(relation = Plink::WalletRecord.scoped)
      @relation = relation
    end

    def plink_point_users_with_wallet
      relation.select('users.firstName, users.emailAddress, wallets.*')
        .joins(:user)
        .where('users.primaryVirtualCurrencyID = ?', Plink::VirtualCurrency.default.id)
    end
  end
end
