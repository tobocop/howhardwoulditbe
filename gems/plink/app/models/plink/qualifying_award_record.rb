module Plink
  class QualifyingAwardRecord < ActiveRecord::Base
    self.table_name = 'qualifyingAwards'

    include Plink::LegacyTimestamps

    alias_attribute :advertiser_id, :advertiserID
    alias_attribute :currency_award_amount, :currencyAwardAmount
    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :is_active, :isActive
    alias_attribute :is_notification_successful, :isNotificationSuccessful
    alias_attribute :is_successful, :isSuccessful
    alias_attribute :user_id, :userID
    alias_attribute :users_virtual_currency_id, :usersVirtualCurrencyID
    alias_attribute :virtual_currency_id, :virtualCurrencyID

    attr_accessible :advertiser_id, :currency_award_amount, :dollar_award_amount, :is_active,
      :is_notification_successful, :is_successful, :user_id, :users_virtual_currency_id,
      :virtual_currency_id

    scope :find_successful_by_user_id, ->(user_id) {
      where('userID = ?', user_id)
      .where('isSuccessful = ?', true)
    }
  end
end
