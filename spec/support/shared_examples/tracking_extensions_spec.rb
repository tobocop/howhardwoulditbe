shared_examples_for(:tracking_extensions) do
  let(:event_service) { double(:create_email_caputre) }
  let(:tracking_object_defaults) {
    {
      affiliate_id: '1',
      campaign_hash: nil,
      campaign_id: nil,
      ip: '0.0.0.0',
      landing_page_id: nil,
      path_id: '1',
      referrer_id: nil,
      sub_id: nil,
      sub_id_four: nil,
      sub_id_three: nil,
      sub_id_two: nil
    }
  }

  let(:url_params) {
    {
      'action' => 'derp',
      'aid' => '1732',
      'c' => 'BIGLONGHASH',
      'controller' => 'herp',
      'pathID' => '123',
      'subID' => 'Subid 1',
      'subID2' => 'Subid 2',
      'subID3' => 'Subid 3',
      'subID4' => 'Subid 4'
    }
  }

  describe 'new_tracking_object' do
    it 'should return a new tracking object' do
      tracking_object = controller.new_tracking_object(sub_id: 'asd')
      tracking_object.should be_a TrackingObject
      tracking_object.sub_id.should == 'asd'
    end
  end

  describe 'new_tracking_object_from_params' do
    it 'should return a new tracking object from passed in params' do
      tracking_object = controller.new_tracking_object_from_params(url_params)
      tracking_object.should be_a TrackingObject
    end

    it 'should return a new tracking object and look up the campaign_id if c is in the params' do
      Plink::EventService.should_receive(:new).and_return(event_service)
      event_service.should_receive(:get_campaign_id).
        with('BIGLONGHASH').
        and_return(4)

      tracking_object = controller.new_tracking_object_from_params(c: 'BIGLONGHASH')
      tracking_object.campaign_id.should == 4
    end
  end

  describe 'new_tracking_object_from_session' do
    it 'returns a new tracking object from the session params' do
      tracking_object = controller.new_tracking_object_from_session
      tracking_object.should be_a TrackingObject
    end
  end

  describe 'set_session_tracking_params' do
    it 'sets session tracking params from a tracking object' do
      tracking_object = controller.new_tracking_object_from_params(url_params)
      controller.set_session_tracking_params(tracking_object)
      session[:tracking_params].should == tracking_object.to_hash
    end
  end

  describe 'get_session_tracking_params' do
    it 'returns a blank hash if session params are not present return session tracking params' do
      controller.get_session_tracking_params.should == {}
    end

    it 'returns session tracking params' do
      tracking_object = controller.new_tracking_object_from_params(url_params)
      controller.set_session_tracking_params(tracking_object)

      controller.get_session_tracking_params.should == tracking_object.to_hash
    end
  end

  describe 'track_email_capture_event' do
    it 'tracks email capture events' do
      Plink::EventService.should_receive(:new).and_return(event_service)
      event_service.should_receive(:create_email_capture).with(3, tracking_object_defaults)

      controller.track_email_capture_event(3)
    end
  end

  describe 'track_registration_start_event' do
    it 'tracks registration start events and store the id in session' do
      Plink::EventService.should_receive(:new).and_return(event_service)
      event_service.should_receive(:create_registration_start).
        with(tracking_object_defaults).
        and_return(double(id: 483))

      controller.track_registration_start_event

      session[:registration_start_event_id].should == 483
    end
  end

  describe 'update_registration_start_event' do
    it 'updates a registration start event with a user id if the session has the id set' do
      session[:registration_start_event_id] = 483

      Plink::EventService.should_receive(:new).and_return(event_service)
      event_service.should_receive(:update_event_user_id).
        with(483, 8)

      controller.update_registration_start_event(8)
    end
  end

  describe 'track_institution_authenticated' do
    it 'tracks institution authenticated events' do
      Plink::EventService.should_receive(:new).and_return(event_service)
      event_service.should_receive(:create_institution_authenticated).with(34, tracking_object_defaults)

      controller.track_institution_authenticated(34)
    end
  end

  describe 'steelhouse_additional_info' do
    it 'returns steelhouse info based on the current virtual currency' do
      controller.stub(:current_virtual_currency).and_return(double(id: 1))

      controller.steelhouse_additional_info.should == '&affiliateid=1,&campaignid=,&landing_page_id=,&subid2=,&subid3=,&subid4=,&subid=,&virtualcurrencyid=1,'
    end
  end

  describe '#plink_card_link_url_generator' do
    it 'initializes and returns a CardLinkUrlGenerator object with the right credentials' do
      card_link_url_generator = double

      Plink::CardLinkUrlGenerator.should_receive(:new).
        with(Plink::Config.instance).
        and_return(card_link_url_generator)

      controller.plink_card_link_url_generator.should == card_link_url_generator
    end
  end
end

