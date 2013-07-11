module Plink
  class InstitutionRecord < ActiveRecord::Base

    self.table_name = 'institutions'

    include Plink::LegacyTimestamps

    alias_attribute :hash_value, :hashValue
    alias_attribute :name, :institutionName
    alias_attribute :intuit_institution_id, :intuitInstitutionID

    attr_accessible :hash_value, :name, :intuit_institution_id
  end
end