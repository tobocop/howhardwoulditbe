module Plink
  class AwardRecord < ActiveRecord::Base
    self.table_name = 'vw_awards'

    alias_attribute :advertiser_name, :advertiserName
    alias_attribute :award_type, :awardType
    alias_attribute :currency_award_amount, :currencyAwardAmount
    alias_attribute :free_award_id, :freeAwardID
    alias_attribute :non_qualifying_award_id, :nonQualifyingAwardID
    alias_attribute :qualifying_award_id, :qualifyingAwardID
    alias_attribute :user_id, :userID

    attr_accessible :advertiser_name, :award_type, :currency_award_amount, :free_award_id,
      :non_qualifying_award_id, :qualifying_award_id, :user_id

    scope :plink_point_awards_pending_notification, -> {
      where('isNotificationSuccessful = ?', false)
      .where('isActive = ?', true)
      .where('isSuccessful = ?', true)
      .where('virtualCurrencyID = ?', Plink::VirtualCurrency.default.id)
    }

    def award_display_name
      advertiser_name.blank? ? award_type : 'visiting ' + advertiser_name
    end
  end
end
