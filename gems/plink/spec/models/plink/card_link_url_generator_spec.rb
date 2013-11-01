require 'spec_helper'

describe Plink::CardLinkUrlGenerator do

  subject { Plink::CardLinkUrlGenerator.new(Plink::Config.instance)}

  describe '.create_url' do
    it 'returns the bare add card URL if no parameters are present' do
      subject.create_url({}).should == 'http://example.com/card_add'
    end

    it 'returns the add card URL with a referrer ID if one is present' do
      subject.create_url(referrer_id: 123).should == 'http://example.com/card_add?refer=123'
    end

    it 'returns the add card URL with the right parameter separator used' do
      subject.stub(:base_url) { 'http://example.com/card_add?test=123' }
      subject.create_url(referrer_id: 123).should == 'http://example.com/card_add?test=123&refer=123'
    end

    it 'returns the add card URL with a landing_page_id if landing_page_id is present' do
      subject.create_url(landing_page_id: '1').should == 'http://example.com/card_add?landing_page_id=1'
    end

    it 'returns the add card URL with a campaignID if campaign_id is present' do
      subject.create_url(campaign_id: 12).should == 'http://example.com/card_add?campaignID=12'
    end

    it 'returns the add card URL with a subID if sub_id present' do
      subject.create_url(sub_id: 'tracking_param').should == 'http://example.com/card_add?subID=tracking_param'
    end

    it 'returns the add card URL with a subID2 if sub_id_two is present' do
      subject.create_url(sub_id_two: 'tracking_param').should == 'http://example.com/card_add?subID2=tracking_param'
    end

    it 'returns the add card URL with a subID3 if sub_id_two is present' do
      subject.create_url(sub_id_three: 'tracking_param').should == 'http://example.com/card_add?subID3=tracking_param'
    end

    it 'returns the add card URL with a subID4 if sub_id_two is present' do
      subject.create_url(sub_id_four: 'tracking_param').should == 'http://example.com/card_add?subID4=tracking_param'
    end

    it 'returns the add card URL with a referrer ID and an affiliate ID if both are present' do
      url_params = {
        affiliate_id: 456,
        referrer_id: 123
      }

      subject.create_url(url_params).should == 'http://example.com/card_add?aid=456&refer=123'
    end

    it 'returns the add card URL with a referrer ID, sub_id_two, and an affiliate ID if all are present' do
      url_params = {
        affiliate_id: 456,
        campaign_id: 4,
        landing_page_id: 2,
        referrer_id: 123,
        sub_id: 'one',
        sub_id_four: 'four',
        sub_id_three: 'three',
        sub_id_two: 'asd'
      }

      subject.create_url(url_params).should == 'http://example.com/card_add?aid=456&campaignID=4&landing_page_id=2&refer=123&subID2=asd&subID3=three&subID4=four&subID=one'
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
