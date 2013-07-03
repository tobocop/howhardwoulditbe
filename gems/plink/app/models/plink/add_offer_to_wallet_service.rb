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
        award_period = create_award_period
        wallet_item.assign_offer(offer_virtual_currency, award_period)
      else
        false
      end
    end

    def create_award_period
      Plink::UsersAwardPeriodRecord.create(user_id: user.id, begin_date: Date.today, advertisers_rev_share: offer.advertisers_rev_share, offers_virtual_currency_id: offer_virtual_currency_for_user.id)
    end

    def offer_virtual_currency_for_user
      offer.active_offers_virtual_currencies.detect { |ovc| ovc.virtual_currency_id == user.primary_virtual_currency_id }
    end
  end
end