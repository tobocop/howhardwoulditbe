module Plink
  class UsersVirtualCurrencyRecord < ActiveRecord::Base

    self.table_name = 'usersVirtualCurrencies'

    include Plink::LegacyTimestamps

    alias_attribute :start_date, :startDate
    alias_attribute :user_id, :userID
    alias_attribute :virtual_currency_id, :virtualCurrencyID

    attr_accessible :start_date, :user_id, :virtual_currency_id

  end
end