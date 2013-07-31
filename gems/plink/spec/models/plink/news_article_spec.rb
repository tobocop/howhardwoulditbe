require 'spec_helper'

describe Plink::NewsArticle do
  let(:attributes) do
    {
      id: 6,
      title: 'boom',
      source: 'a magazine',
      source_link: 'http://example.com/magazine',
      is_active: true,
      published_on: Date.today
    }
  end

  subject { Plink::NewsArticle.new(attributes) }

  it 'takes its attributes from the given hash' do
    subject.id.should == 6
    subject.title.should == 'boom'
    subject.source.should == 'a magazine'
    subject.source_link.should == 'http://example.com/magazine'
    subject.is_active.should == true
    subject.published_on.should == Date.today
  end
end
