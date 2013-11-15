module Plink
  class UserEligibleForOfferAddBonusRecord < ActiveRecord::Base
    self.table_name = 'users_eligible_for_offer_add_bonus'

    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'user_id'

    attr_accessible :is_awarded, :offers_virtual_currency_id, :user_id

    validates_uniqueness_of :user_id, scope: :offers_virtual_currency_id
  end
end
