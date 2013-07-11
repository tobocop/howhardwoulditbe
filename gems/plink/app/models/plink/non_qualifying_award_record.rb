module Plink
  class NonQualifyingAwardRecord < ActiveRecord::Base

    self.table_name = 'nonQualifyingAwards'

    include Plink::LegacyTimestamps

    alias_attribute :currency_award_amount, :currencyAwardAmount
    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :user_id, :userID
    alias_attribute :users_virtual_currency_id, :usersVirtualCurrencyID
    alias_attribute :virtual_currency_id, :virtualCurrencyID
    alias_attribute :advertiser_id, :advertiserID
    alias_attribute :is_successful, :isSuccessful
    alias_attribute :is_notification_successful, :isNotificationSuccessful

    attr_accessible :currency_award_amount, :dollar_award_amount, :user_id, :users_virtual_currency_id, :virtual_currency_id, :advertiser_id, :is_successful, :is_notification_successful

  end
end