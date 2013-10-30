module Plink
  class NonQualifyingAwardRecord < ActiveRecord::Base
    self.table_name = 'nonQualifyingAwards'

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
  end
end
