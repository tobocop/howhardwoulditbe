require 'spec_helper'

describe Plink::CardLinkUrlGenerator do

  subject { Plink::CardLinkUrlGenerator.new(Plink::Config.instance)}

  describe '.create_url' do
    it 'returns the bare URL if referrer_id is blank' do
      subject.create_url(referrer_id: '').should == 'http://example.com/card_add'
    end

    it 'returns the add card URL with a referrer ID if one is present' do
      subject.create_url(referrer_id: 123).should == 'http://example.com/card_add?refer=123'
    end

    it 'returns the add card URL with the right parameter separator used' do
      subject.stub(:base_url) { 'http://example.com/card_add?test=123' }
      subject.create_url(referrer_id: 123).should == 'http://example.com/card_add?test=123&refer=123'
    end

    it 'returns the bare add card URL if only an affiliate ID is present' do
      subject.create_url(affiliate_id: 456).should == 'http://example.com/card_add'
    end

    it 'returns the add card URL with a referrer ID and an affiliate ID if both are present' do
      subject.create_url(referrer_id: 123, affiliate_id: 456).should == 'http://example.com/card_add?refer=123&aid=456'
    end
  end

  describe 'change_url' do
    it 'should return the configured URL' do
      subject.change_url.should == 'http://example.com/card_change_url'
    end
  end

  describe 'card_reverify_url' do
    it 'should return the correct reverify URL' do
      subject.card_reverify_url.should == 'http://www.example.com/card_reverify_url'
    end
  end
end