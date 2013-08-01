module Plink
  class NewsArticleService
    def news_articles
      create_news_articles(NewsArticleRecord.active.by_publish_date)
    end

    private

    def create_news_articles(news_article_records)
      news_article_records.map { |article| create_news_article(article) }
    end

    def create_news_article(news_article_record)
      NewsArticle.new(
        id: news_article_record.id,
        title: news_article_record.title,
        source: news_article_record.source,
        source_link: news_article_record.source_link,
        published_on: news_article_record.published_on,
        is_active: news_article_record.is_active
      )
    end
  end
end