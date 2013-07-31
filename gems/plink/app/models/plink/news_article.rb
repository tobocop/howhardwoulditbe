module Plink
  class NewsArticle

    attr_reader :id, :title, :source, :source_link, :is_active, :published_on

    def initialize(attributes)
      @id = attributes.fetch(:id)
      @title = attributes.fetch(:title)
      @source = attributes.fetch(:source)
      @source_link = attributes.fetch(:source_link)
      @is_active = attributes.fetch(:is_active)
      @published_on = attributes.fetch(:published_on)
    end
  end
end