module Plink
  class UserEligibleForOfferAddBonusRecord < ActiveRecord::Base
    self.table_name = 'users_eligible_for_offer_add_bonus'

    attr_accessible :offers_virtual_currency_id, :user_id

    validates_uniqueness_of :user_id, scope: :offers_virtual_currency_id
  end
end
