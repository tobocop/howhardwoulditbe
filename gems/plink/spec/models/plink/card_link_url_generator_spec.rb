require 'spec_helper'

describe Plink::CardLinkUrlGenerator do
  describe '.create_url' do
    before do
      Plink::CardLinkUrlGenerator.stub(:base_url) { 'http://www.example.com/' }
    end

    it 'returns the bare URL if referrer_id is blank' do
      Plink::CardLinkUrlGenerator.create_url(referrer_id: '').should == 'http://www.example.com/'
    end

    it 'returns the add card URL with a referrer ID if one is present' do
      Plink::CardLinkUrlGenerator.create_url(referrer_id: 123).should == 'http://www.example.com/?refer=123'
    end

    it 'returns the add card URL with the right parameter separator used' do
      Plink::CardLinkUrlGenerator.stub(:base_url) { 'http://www.example.com/?test=123' }
      Plink::CardLinkUrlGenerator.create_url(referrer_id: 123).should == 'http://www.example.com/?test=123&refer=123'
    end

    it 'returns the bare add card URL if only an affiliate ID is present' do
      Plink::CardLinkUrlGenerator.create_url(affiliate_id: 456).should == 'http://www.example.com/'
    end

    it 'returns the add card URL with a referrer ID and an affiliate ID if both are present' do
      Plink::CardLinkUrlGenerator.create_url(referrer_id: 123, affiliate_id: 456).should == 'http://www.example.com/?refer=123&aid=456'
    end
  end

  describe '.base_url' do
    it 'returns the Rails config option for the coldfusion card add url' do
      Rails.application.config.stub(:coldfusion_card_add_url) { 'http://www.example.com/' }
      Plink::CardLinkUrlGenerator.base_url.should == 'http://www.example.com/'
    end
  end
end