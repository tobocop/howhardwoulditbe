module Plink
  class EventTypeRecord < ActiveRecord::Base

    self.table_name = 'eventTypes'

    include Plink::LegacyTimestamps

    attr_accessible :name

    TYPES = {
      :email_capture_type => 'userRegistration'
    }


    def self.for_name(name)
      where('name = ?', name).first
    end

    def self.email_capture_type
      TYPES[:email_capture_type]
    end


  end
end