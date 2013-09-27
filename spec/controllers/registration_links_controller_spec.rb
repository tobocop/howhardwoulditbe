require 'spec_helper'

describe RegistrationLinksController do
  let(:landing_page) { create_landing_page(partial_path: 'path.html.haml') }
  let(:affiliate) { create_affiliate }
  let(:campaign) { create_campaign }

  let!(:registration_link) {
    create_registration_link(
      affiliate_id: affiliate.id,
      campaign_id: campaign.id,
      start_date: 1.day.ago,
      end_date: 1.day.from_now,
      landing_page_records: [landing_page]
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

    it 'redirects to the homepage if the registration_path is not live' do
      get :show, id: expired_registration_link.id

      response.should be_redirect
    end

    it 'assigns registration_path' do
      get :show, id: registration_link.id
      assigns(:registration_path).should be_present
      assigns(:registration_path).landing_page_partial.should == 'path.html.haml'
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
    end
  end
end
