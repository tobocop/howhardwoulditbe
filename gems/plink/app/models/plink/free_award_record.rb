module Plink
  class FreeAwardRecord < ActiveRecord::Base
    self.table_name = 'freeAwards'

    include Plink::LegacyTimestamps

    alias_attribute :award_type_id, :awardTypeID
    alias_attribute :currency_award_amount, :currencyAwardAmount
    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :user_id, :userID
    alias_attribute :is_active, :isActive
    alias_attribute :users_virtual_currency_id, :usersVirtualCurrencyID
    alias_attribute :virtual_currency_id, :virtualCurrencyID
    alias_attribute :is_successful, :isSuccessful
    alias_attribute :is_notification_successful, :isNotificationSuccessful

    attr_accessible :award_type_id, :currency_award_amount, :dollar_award_amount, :user_id, :is_active, :users_virtual_currency_id, :virtual_currency_id, :is_successful, :is_notification_successful

  end
end