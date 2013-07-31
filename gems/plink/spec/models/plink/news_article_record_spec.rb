require 'spec_helper'

describe Plink::NewsArticleRecord do
  let(:valid_params) {
    {
      source: 'TechCrunch',
      source_link: 'http://techcrunch.com/plink',
      published_on: Date.today,
      title: 'the news',
      is_active: true
    }
  }

  subject { Plink::NewsArticleRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::NewsArticleRecord.create(valid_params).should be_persisted
  end

  describe '.active' do
    before do
      @active_article = create_news_article(is_active: true)
      inactive_article = create_news_article(is_active: false)
    end

    it 'returns only active news articles' do
      Plink::NewsArticleRecord.active.should == [@active_article]
    end
  end
end
