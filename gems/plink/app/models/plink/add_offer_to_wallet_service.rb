module Plink
  class AddOfferToWalletService
    attr_accessor :offer, :user

    def initialize(params)
      self.offer = params.fetch(:offer)
      self.user = params.fetch(:user)
    end

    def add_offer
      wallet_item = user.empty_wallet_item
      offer_virtual_currency = offer_virtual_currency_for_user

      if wallet_item.present? && offer_virtual_currency.present?
        wallet_item.assign_offer(offer_virtual_currency)
      else
        false
      end
    end

    def offer_virtual_currency_for_user
      offer.active_offers_virtual_currencies.detect { |ovc| ovc.virtual_currency_id == user.primary_virtual_currency_id }
    end
  end
end