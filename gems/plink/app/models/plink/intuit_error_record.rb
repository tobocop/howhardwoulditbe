module Plink
  class IntuitErrorRecord < ActiveRecord::Base
    self.table_name = 'intuitErrors'

    attr_accessible :error_description, :error_prefix, :intuit_error_id, :user_message

    alias_attribute :error_description, :errorDescription
    alias_attribute :error_prefix, :errorPrefix
    alias_attribute :intuit_error_id, :intuitErrorID
    alias_attribute :user_message, :userMessage

    validates_presence_of :error_description, :error_prefix
  end
end
