module Plink
  class RemoveOfferFromWalletService
    attr_accessor :offer, :user

    def initialize(params)
      self.user = params.fetch(:user)
      self.offer = params.fetch(:offer)
    end

    def remove_offer
      item = wallet_item_for_offer
      if item
        WalletItemHistoryRecord.clone_from_wallet_item(item)
        item.unassign_offer
      else
        true
      end
    end

    def wallet_item_for_offer
      offers_virtual_currency = offer_virtual_currency_for_user
      if offers_virtual_currency
        wallet.wallet_item_for_offer(offers_virtual_currency)
      else
        nil
      end
    end

    def wallet
      user.wallet
    end

    def offer_virtual_currency_for_user
      offer.active_offers_virtual_currencies.detect { |ovc| ovc.virtual_currency_id == user.primary_virtual_currency_id }
    end
  end
end