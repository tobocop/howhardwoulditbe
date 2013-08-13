require 'spec_helper'

describe Plink::EventService do

  let(:default_params) {
    {
      affiliate_id: 123,
      sub_id: nil,
      sub_id_two: nil,
      sub_id_three: nil,
      sub_id_four: nil,
      path_id: '1',
      campaign_hash: 'MYSUPERAWESOMEHASH',
      ip: '127.0.0.1'
    }
  }

  let(:user_id) { 456 }

  describe '.create_email_capture' do

    before :each do
      @event_type = create_event_type(name: 'emailCapture')
      Plink::EventService.any_instance.stub(:email_event_type) {'emailCapture'}
    end

    it 'should be successful' do
      campaign = create_campaign(campaign_hash: 'MYSUPERAWESOMEHASH')
      Plink::EventRecord.should_receive(:create).with(
        user_id: user_id,
        affiliate_id: 123,
        sub_id: nil,
        sub_id_two: nil,
        sub_id_three: nil,
        sub_id_four: nil,
        path_id: '1',
        campaign_id: campaign.id,
        event_type_id: @event_type.id,
        ip: '127.0.0.1'
      )
      Plink::EventService.new.create_email_capture(user_id, default_params)
    end

    it 'should be successful when no campaigns exist' do
      Plink::EventRecord.should_receive(:create).with(
        user_id: user_id,
        affiliate_id: 123,
        sub_id: nil,
        sub_id_two: nil,
        sub_id_three: nil,
        sub_id_four: nil,
        path_id: '1',
        campaign_id: nil,
        event_type_id: @event_type.id,
        ip: '127.0.0.1'
      )
      Plink::EventService.new.create_email_capture(user_id, default_params)
    end
  end

  describe '.get_campaign_id' do
    before :each do
      @expected_campaign = create_campaign(campaign_hash: 'HASHY')
    end

    it 'returns a campaign_id given a campaign hash' do
      campaign_id = Plink::EventService.new.get_campaign_id('HASHY')
      campaign_id.should == @expected_campaign.id
    end

    it 'returns nil when it cannot be found' do
      campaign_id = Plink::EventService.new.get_campaign_id('NOPE')
      campaign_id.should be_nil
    end
  end
end
