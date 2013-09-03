module Plink

  class TangoRedemptionLimitRecord < ActiveRecord::Base

    self.table_name = 'vw_tango24hourRedemptions'

    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'userID'

    alias_attribute :user_id, :userID
    alias_attribute :hold_redemptions, :holdRedemptions
    alias_attribute :redemption_count, :redemptionCount
    alias_attribute :redeemed_in_past_24_hours, :redeemedInPast24Hours

  end
end