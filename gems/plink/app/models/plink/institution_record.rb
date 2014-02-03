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

    settings analysis: {
      filter: {
        url_ngram: {
          type: 'nGram',
          min_gram: 4,
          max_gram: 10
        }
      },
      analyzer: {
        url_analyzer: {
          type: 'custom',
          tokenizer: 'lowercase',
          filter: ['stop', 'url_ngram']
        }
      }
    } do
      mapping do
        indexes :homeURL, type: 'string', analyzer: 'url_analyzer'
        indexes :institutionName, type: 'string'
      end
    end

    def self.search(search_term, limit=100)
      tire.search(load: true, per_page: limit) do
        query { match [:homeURL, :institutionName], search_term } if search_term.present?
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
