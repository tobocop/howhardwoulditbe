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

  it "sets the created field on create (to mirror created_at)" do
    subject.created_at.should be_nil
    subject.save!
    subject.created_at.should be_a Time
  end

  it "does not update the created time on update" do
    subject.save!
    created_at = subject.created_at
    subject.touch
    subject.created_at.should == created_at
  end

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