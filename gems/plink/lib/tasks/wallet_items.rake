namespace :wallet_items do

  desc "Unlock wallet items for users who have a qualifying transaction"
  task :unlock_transaction_wallet_item => :environment do
    Plink::WalletItemUnlockingService.unlock_transaction_items_for_eligible_users
  end

end