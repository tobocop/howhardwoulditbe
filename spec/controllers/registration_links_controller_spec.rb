require 'spec_helper'

describe RegistrationLinksController do
  let(:landing_page) { create_landing_page(partial_path: 'path.html.haml') }
  let(:affiliate) { create_affiliate }
  let(:campaign) { create_campaign(campaign_hash: 'fordeprecation') }

  let!(:registration_link) {
    create_registration_link(
      affiliate_id: affiliate.id,
      campaign_id: campaign.id,
      start_date: 1.day.ago,
      end_date: 1.day.from_now,
      landing_page_records: [landing_page],
      mobile_detection_on: false
    )
  }

  let!(:expired_registration_link) {
    create_registration_link(
      start_date: 1.day.from_now,
      end_date: 2.days.from_now,
      landing_page_records: [landing_page]
    )
  }

  describe 'GET show' do
    let!(:registration_start_event_type) { create_event_type(name: Plink::EventTypeRecord.registration_start_type) }
    let!(:virtual_currency) { create_virtual_currency }

    it 'redirects to the homepage if the registration_flow is not live' do
      get :show, id: expired_registration_link.id

      response.should be_redirect
    end

    it 'assigns registration_flow' do
      get :show, id: registration_link.id

      assigns(:registration_flow).should be_present
      assigns(:registration_flow).landing_page_partial.should == 'path.html.haml'
    end

    context 'mobile detection' do
      let!(:mobile_registration_link) {
        create_registration_link(
          affiliate_id: affiliate.id,
          campaign_id: campaign.id,
          start_date: 1.day.ago,
          end_date: 1.day.from_now,
          landing_page_records: [landing_page],
          mobile_detection_on: true
        )
      }

      let(:url_params) {
        {
          'subID' => 'SubidOne',
          'subID2' => 'SubidTwo',
          'subID3' => 'SubidThree',
          'subID4' => 'SubidFour',
          'randomParameter' => 'willbeforwarded',
          id: mobile_registration_link.id
        }
      }

      it 'redirects the user to the cf mobile registration path with all url params' do
        request.user_agent = 'Mobile'

        get :show, url_params

        response.location.should =~ /http:\/\/www\.plink\.dev\/index\.cfm\?fuseaction=mobile\.register/
        response.location.should =~ /aid=#{affiliate.id}/
        response.location.should =~ /campaignID=#{campaign.id}/
        response.location.should =~ /subID=SubidOne/
        response.location.should =~ /subID2=SubidTwo/
        response.location.should =~ /subID3=SubidThree/
        response.location.should =~ /subID4=SubidFour/
        response.location.should =~ /randomParameter=willbeforwarded/
      end

      it 'does not redirect when a user is not on a mobile browser' do
        get :show, url_params
        response.should_not be_redirect
      end
    end

    context 'tracking' do
      let(:url_params) {
        {
          'subID' => 'Subid 1',
          'subID2' => 'Subid 2',
          'subID3' => 'Subid 3',
          'subID4' => 'Subid 4',
          id: registration_link.id
        }
      }

      before  { get :show, url_params }

      it 'sets the tracking_params affiliate_id in the session to what it is for the current registration link' do
        session[:tracking_params][:affiliate_id].should == affiliate.id
      end

      it 'sets the tracking_params campaign_id in the session to what it is for the current registration link' do
        session[:tracking_params][:campaign_id].should == campaign.id
      end

      it 'sets the tracking_params in the session to what was passed in via the url for subids' do
        session[:tracking_params][:sub_id].should == 'Subid 1'
        session[:tracking_params][:sub_id_two].should == 'Subid 2'
        session[:tracking_params][:sub_id_three].should == 'Subid 3'
        session[:tracking_params][:sub_id_four].should == 'Subid 4'
      end

      it 'tracks a registration start event' do
        event = Plink::EventRecord.last
        event.event_type_id.should == registration_start_event_type.id
        event.landing_page_id.should == landing_page.id
        event.affiliate_id.should == affiliate.id
        event.campaign_id.should == campaign.id
        event.sub_id.should == 'Subid 1'
        event.sub_id_two.should == 'Subid 2'
        event.sub_id_three.should == 'Subid 3'
        event.sub_id_four.should == 'Subid 4'
      end

      it 'sets the session registration_start_event_id to the tracked events id' do
        event = Plink::EventRecord.last
        session[:registration_start_event_id].should == event.id
      end

      it 'should assign the steelhouse additional info string' do
        assigns(:steelhouse_additional_info).should == "&affiliateid=#{affiliate.id},&subid=subid 1,&subid2=subid 2,&subid3=subid 3,&subid4=subid 4,&campaignid=#{campaign.id},&virtualcurrencyid=#{virtual_currency.id},&landing_page_id=#{landing_page.id},"
      end
    end
  end

  describe 'GET deprecated' do
    let(:url_params) {
      {
        'subID' => 'Subid1',
        'subID2' => 'Subid2',
        'subID3' => 'Subid3',
        'subID4' => 'Subid4',
        aid: affiliate.id,
        c: campaign.campaign_hash
      }
    }

    before do
      create_registration_link_mapping(affiliate_id: affiliate.id, campaign_id: campaign.id, registration_link_id: registration_link.id)
    end

    it 'looks up a registration link by affiliate_id and campaign_hash and forwards the user to the new link' do
      get :deprecated, url_params
      response.should redirect_to "/registration_links/#{registration_link.id}?subID2=Subid2&subID3=Subid3&subID4=Subid4&subID=Subid1"
    end

    it 'redirects to the homepage if a link cannot be found' do
      get :deprecated, url_params.except(:aid)
      response.should be_redirect
    end
  end
end
