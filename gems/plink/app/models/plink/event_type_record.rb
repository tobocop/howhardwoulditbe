module Plink
  class EventTypeRecord < ActiveRecord::Base

    self.table_name = 'eventTypes'

    include Plink::LegacyTimestamps

    attr_accessible :name

    TYPES = {
      :email_capture_type => 'userRegistration',
      :impression_type => 'impression',
      :login_type => 'login'
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

  end
end