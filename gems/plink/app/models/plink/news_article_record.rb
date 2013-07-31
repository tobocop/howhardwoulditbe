module Plink
  class NewsArticleRecord < ActiveRecord::Base

    include Plink::LegacyTimestamps

    self.table_name = 'newsArticles'

    alias_attribute :source_link, :sourceLink
    alias_attribute :published_on, :publishedOn
    alias_attribute :is_active, :isActive

    attr_accessible :source, :source_link, :published_on, :title, :is_active

    def self.active
      where(isActive: true)
    end
  end
end