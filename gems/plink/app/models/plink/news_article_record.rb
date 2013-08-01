module Plink
  class NewsArticleRecord < ActiveRecord::Base

    self.table_name = 'newsArticles'

    alias_attribute :source_link, :sourceLink
    alias_attribute :published_on, :publishedOn
    alias_attribute :is_active, :isActive

    attr_accessible :source, :source_link, :published_on, :title, :is_active

    def self.active
      where(isActive: true)
    end

    def created_at
      self.created
    end

    def self.by_publish_date
      order('publishedOn Desc')
    end

    private

    def timestamp_attributes_for_create
      super << :created
    end

  end
end