require 'tire'

module Plink
  class InstitutionRecord < ActiveRecord::Base
    self.table_name = 'institutions'

    include Plink::LegacyTimestamps
    include ::Tire::Model::Search
    include ::Tire::Model::Callbacks

    alias_attribute :hash_value, :hashValue
    alias_attribute :home_url, :homeURL
    alias_attribute :institution_id, :institutionID
    alias_attribute :intuit_institution_id, :intuitInstitutionID
    alias_attribute :is_active, :isActive
    alias_attribute :is_supported, :isSupported
    alias_attribute :logo_url, :logoURL
    alias_attribute :name, :institutionName

    attr_accessible :hash_value, :home_url, :intuit_institution_id, :is_active,
      :is_supported, :logo_url, :name

    mapping do
      indexes :institutionName, type: 'string', boost: 10
    end

    def self.search(search_term, limit=100)
      tire.search(load: true, per_page: limit) do
        query { string search_term, default_operator: "AND" } if search_term.present?
      end
    end

    scope :most_popular, ->(limit=16) {
      select("COUNT(1) AS frequency, institutionName, institutions.institutionID, isSupported").
      joins('INNER JOIN usersInstitutions ON institutions.institutionID = usersInstitutions.institutionID').
      where('institutions.isActive = 1 AND isSupported = 1').
      group('institutions.institutionID, institutions.institutionName, isSupported').
      order('frequency DESC').
      limit(limit)
    }
  end
end
