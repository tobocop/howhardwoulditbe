module Plink
  class ReferralConversionRecord < ActiveRecord::Base
    self.table_name = 'referralConversions'

    attr_accessible :referred_by, :created_user_id

    alias_attribute :referred_by, :referredBy
    alias_attribute :created_user_id, :createdUserID

    def created_at
      self.created
    end

    private

    def timestamp_attributes_for_create
      super << :created
    end

  end
end