require 'spec_helper'

describe Plink::NewsArticleService do

  subject { Plink::NewsArticleService.new }

  describe '#news_articles' do
    before do
      create_news_article(title: 'good article')
      create_news_article(is_active: false, title: 'bad article')
    end

    it 'returns all active news articles' do
      articles = subject.news_articles

      articles.count.should == 1

      article = articles.first

      article.title.should == 'good article'
      article.should be_a Plink::NewsArticle
    end
  end
end
