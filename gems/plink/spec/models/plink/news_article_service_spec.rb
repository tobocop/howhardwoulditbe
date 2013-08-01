require 'spec_helper'

describe Plink::NewsArticleService do

  subject { Plink::NewsArticleService.new }

  describe '#news_articles' do
    before do
      create_news_article(is_active: true, title: 'bad article', published_on: Date.yesterday)
      create_news_article(is_active: true, title: 'good article', published_on: Date.today)
      create_news_article(is_active: false, title: 'bad article')
    end

    it 'returns all active news articles' do
      articles = subject.news_articles

      articles.count.should == 2
      articles.map(&:class).uniq.should == [Plink::NewsArticle]
      articles.map(&:title).should == ['good article', 'bad article']
    end
  end
end
