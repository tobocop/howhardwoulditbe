module Plink
  class FreeAwardService
    attr_reader :dollar_award_amount

    def initialize(dollar_award_amount)
      @dollar_award_amount = dollar_award_amount
    end

    def award_user_incented_affiliate(user_id)
      award(user_id, Plink::AwardTypeRecord.incented_affiliate_award_type_id)
    end

    def award_referral_bonus(user_id)
      award(user_id, Plink::AwardTypeRecord.referral_bonus_award_type_id)
    end

    def award_unique(user_id, award_type_id)
      award(user_id, award_type_id) unless Plink::FreeAwardRecord.awards_by_type_and_by_user_id(award_type_id, user_id).present?
    end

    def award(user_id, award_type_id)
      user = Plink::UserService.new.find_by_id(user_id)
      users_virtual_currency = get_users_virtual_currency(user.id, user.primary_virtual_currency_id)
      create_params = {
        award_type_id: award_type_id,
        currency_award_amount: dollar_award_amount * 100,
        dollar_award_amount: dollar_award_amount,
        is_active: true,
        is_notification_successful: false,
        is_successful: true,
        user_id: user.id,
        users_virtual_currency_id: users_virtual_currency.id,
        virtual_currency_id: user.primary_virtual_currency_id
      }

      Plink::FreeAwardRecord.create(create_params)
    end

  private

    def get_users_virtual_currency(user_id, virtual_currency_id)
      Plink::UsersVirtualCurrencyRecord.where(userID: user_id, virtualCurrencyID: virtual_currency_id).first
    end
  end
end
