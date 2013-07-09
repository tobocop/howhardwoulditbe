module Plink
  class EmptyWalletItemRecord < WalletItemRecord

    def locked?
      false
    end
  end
end