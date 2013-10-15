module WalletHelper
  def show_promotional_wallet_item(wallet)
    Time.zone.now < end_promotion_date && !wallet.has_unlocked_promotion_slot
  end

private

  def end_promotion_date
    Time.zone.parse('2013-10-28 00:00:00')
  end
end