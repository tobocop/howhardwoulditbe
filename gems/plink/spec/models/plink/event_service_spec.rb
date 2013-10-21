require 'spec_helper'

describe Plink::EventService do
  let(:user_id) { 456 }
  let(:default_params) {
    {
      affiliate_id: 123,
      sub_id: nil,
      sub_id_two: nil,
      sub_id_three: nil,
      sub_id_four: nil,
      path_id: '1',
      campaign_id: 23,
      landing_page_id: 12,
      ip: '127.0.0.1'
    }
  }

  describe '.get_card_add_event' do
    let!(:card_add_event_type) { create_event_type(name: Plink::EventTypeRecord.card_add_type) }

    it 'returns the event associated to a user linking a card' do
      create_event(user_id: user_id)
      created_event = create_event(user_id: user_id, event_type_id: card_add_event_type.id)
      create_event(user_id: user_id)

      event = Plink::EventService.get_card_add_event(user_id)
      event.id.should == created_event.id
      event.event_type_id.should == card_add_event_type.id
    end

    it 'returns nil if no event exists' do
      Plink::EventService.get_card_add_event(2348967234).should be_nil
    end
  end

  describe '.get_email_capture_event' do
    let!(:email_capture_event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }

    it 'returns the event associated to a user linking a card' do
      create_event(user_id: user_id)
      created_event = create_event(user_id: user_id, event_type_id: email_capture_event_type.id)
      create_event(user_id: user_id)

      event = Plink::EventService.get_email_capture_event(user_id)
      event.id.should == created_event.id
      event.event_type_id.should == email_capture_event_type.id
    end

    it 'returns nil if no event exists' do
      Plink::EventService.get_email_capture_event(2348967234).should be_nil
    end
  end

  describe '#create_email_capture' do
    let(:event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }

    it 'should be successful' do
      Plink::EventRecord.should_receive(:create).with(
        user_id: user_id,
        affiliate_id: 123,
        sub_id: nil,
        sub_id_two: nil,
        sub_id_three: nil,
        sub_id_four: nil,
        path_id: '1',
        campaign_id: 23,
        landing_page_id: 12,
        event_type_id: event_type.id,
        ip: '127.0.0.1'
      )
      Plink::EventService.new.create_email_capture(user_id, default_params)
    end

    #TODO: this is for legacy code that should be removed with #57665410
      it 'should be successful without a campaign_id and with a campaign_hash' do
        campaign = create_campaign(campaign_hash: 'AWESOME')

        Plink::EventRecord.should_receive(:create).with(
          user_id: user_id,
          affiliate_id: 123,
          sub_id: nil,
          sub_id_two: nil,
          sub_id_three: nil,
          sub_id_four: nil,
          path_id: '1',
          campaign_id: campaign.id,
          landing_page_id: nil,
          event_type_id: event_type.id,
          ip: '127.0.0.1'
        )
        new_params = default_params.except!(:campaign_id, :landing_page_id).merge(campaign_hash:'AWESOME')
        Plink::EventService.new.create_email_capture(user_id, new_params)
      end
  end

  describe '#create_registration_start' do
    let(:event_type) { create_event_type(name: Plink::EventTypeRecord.registration_start_type) }

    it 'should be successful' do
      Plink::EventRecord.should_receive(:create).with(
        user_id: 0,
        affiliate_id: 123,
        sub_id: nil,
        sub_id_two: nil,
        sub_id_three: nil,
        sub_id_four: nil,
        path_id: '1',
        campaign_id: 23,
        landing_page_id: 12,
        event_type_id: event_type.id,
        ip: '127.0.0.1'
      )

      Plink::EventService.new.create_registration_start(default_params)
    end
  end

  describe '#get_campaign_id' do
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

  describe '#update_event_user_id' do
    let!(:event) { create_event(user_id: nil) }

    it 'looks up the event by the event_id passed in' do
      Plink::EventRecord.should_receive(:find).with(5).and_return { double(update_attribute: true) }

      Plink::EventService.new.update_event_user_id(5, 3)
    end

    it 'updates an event with the passed in user_id' do
      Plink::EventService.new.update_event_user_id(event.id, 3)

      event.reload.user_id.should == 3
    end
  end
end
