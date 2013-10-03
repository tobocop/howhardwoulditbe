module Plink
  class RemoveOfferFromWalletService
    attr_accessor :offer_record, :user_record

    def initialize(user_id, offer_id)
      self.user_record = Plink::UserRecord.find(user_id)
      self.offer_record = Plink::OfferRecord.find(offer_id)
    end

    def remove_offer
      item = wallet_item_for_offer
      if item
        users_award_period = Plink::UsersAwardPeriodRecord.find(item.users_award_period_id)
        users_award_period.update_attributes(end_date: Date.current)
        WalletItemHistoryRecord.clone_from_wallet_item(item)
        item.unassign_offer
      else
        true
      end
    end

  private

    def wallet_item_for_offer
      offers_virtual_currency = offer_virtual_currency_for_user
      if offers_virtual_currency
        wallet.wallet_item_for_offer(offers_virtual_currency)
      else
        nil
      end
    end

    def wallet
      Plink::Wallet.new(user_record.wallet)
    end

    def offer_virtual_currency_for_user
      offer_record.active_offers_virtual_currencies.detect { |ovc| ovc.virtual_currency_id == user_record.primary_virtual_currency_id }
    end
  end
end