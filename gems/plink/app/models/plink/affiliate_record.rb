module Plink
  class AffiliateRecord < ActiveRecord::Base

    self.table_name = 'affiliates'

    alias_attribute :name, :affiliate
    alias_attribute :has_incented_card_registration, :hasIncentedCardRegistration
    alias_attribute :card_registration_dollar_award_amount, :cardRegistrationDollarAwardAmount
    alias_attribute :has_incented_join, :hasIncentedJoin
    alias_attribute :join_dollar_award_amount, :joinDollarAwardAmount
    alias_attribute :card_add_pixel, :cardAddPixel
    alias_attribute :email_add_pixel, :emailAddPixel
    alias_attribute :disclaimer_text, :disclaimerText
    

    attr_accessible :name, :has_incented_card_registration, :card_registration_dollar_award_amount, :has_incented_join,
      :join_dollar_award_amount, :card_add_pixel, :email_add_pixel, :disclaimer_text

    validates_presence_of :name

    def created_at
      self.created
    end

    private

    def timestamp_attributes_for_create
      super << :created
    end
  end
end
