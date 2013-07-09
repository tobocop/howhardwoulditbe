module Plink
  class LockedWalletItemRecord < WalletItemRecord

    def locked?
      true
    end
  end
end