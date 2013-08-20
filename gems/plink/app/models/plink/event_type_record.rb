module Plink
  class EventTypeRecord < ActiveRecord::Base

    self.table_name = 'eventTypes'

    include Plink::LegacyTimestamps

    attr_accessible :name

    TYPES = {
      :email_capture_type => 'userRegistration',
      :impression_type => 'impression',
      :login_type => 'login',
      :card_add_type => 'credentialRegistration',
      :card_change_type => 'cardChange',
      :facebook_login_type => 'facebookLogin',
      :offer_activate_type => 'offerWallActivate',
      :offer_deactivate_type => 'offerWallDeactivate'
    }


    def self.for_name(name)
      where('name = ?', name).first
    end

    def self.email_capture_type
      TYPES[:email_capture_type]
    end

    def self.impression_type
      TYPES[:impression_type]
    end

    def self.login_type
      TYPES[:login_type]
    end

    def self.card_add_type
      TYPES[:card_add_type]
    end

    def self.card_change_type
      TYPES[:card_change_type]
    end

    def self.facebook_login_type
      TYPES[:facebook_login_type]
    end

    def self.offer_activate_type
      TYPES[:offer_activate_type]
    end

    def self.offer_deactivate_type
      TYPES[:offer_deactivate_type]
    end
  end
end
