require 'spec_helper'

describe PlinkAdmin::RegistrationLinksController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    let!(:registration_link) { create_registration_link }

    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all registration_links in the database' do
      assigns(:registration_links).should == [registration_link]
    end
  end

  describe 'GET new' do
    let!(:affiliate) { create_affiliate }
    let!(:campaign) { create_campaign }
    let!(:landing_page) { create_landing_page }

    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new registration_link' do
      assigns(:registration_link).should be_present
      assigns(:registration_link).should_not be_persisted
    end

    it 'gets all affiliates' do
      assigns(:affiliates).should be_present
      assigns(:affiliates).should == [affiliate]
    end

    it 'gets all campaigns' do
      assigns(:campaigns).should be_present
      assigns(:campaigns).should == [campaign]
    end

    it 'gets all landing pages' do
      assigns(:landing_pages).should be_present
      assigns(:landing_pages).should == [landing_page]
    end
  end

  describe 'POST create' do
    let(:first_landing_page) { create_landing_page }
    let(:second_landing_page) { create_landing_page }
    let(:registration_link_params) {
      {
        affiliate_ids: [134, 123],
        campaign_id: 2,
        is_active: true,
        landing_page_ids:[first_landing_page.id, second_landing_page.id],
        start_date: { 'start_date(1i)'=>'2013', 'start_date(2i)'=>'9', 'start_date(3i)'=>'23' },
        end_date: { 'end_date(1i)'=>'2013', 'end_date(2i)'=>'9', 'end_date(3i)'=>'25' }
      }
    }

    let(:registration_links) {Plink::RegistrationLinkRecord.all}

    it 'creates a registration_link_record for each affiliate_id' do
      post :create, registration_link_params

      registration_links.length.should == 2

      registration_links.first.affiliate_id.should == 134
      registration_links.last.affiliate_id.should == 123

      response.should redirect_to '/registration_links'
    end

    it 'sets the campaign_id to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:campaign_id).uniq.should == [2]
    end

    it 'sets the start_date to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:start_date).uniq.should == [Time.zone.local(2013, 9, 23)]
    end

    it 'sets the end_date to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:end_date).uniq.should == [Time.zone.local(2013, 9, 25)]
    end

    it 'sets is_active to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:is_active).uniq.should == [true]
    end

    it 'creates groupings of landing pages for each link' do
      post :create, registration_link_params

      registration_links.first.landing_page_records.should == [first_landing_page, second_landing_page]
      registration_links.last.landing_page_records.should == [first_landing_page, second_landing_page]
    end

    it 'does not need landing pages to be successful' do
      post :create, registration_link_params.except(:landing_page_ids)

      registration_links.length.should == 2
      response.status.should == 302
    end

    it 'sets a flash error and re-renders the form if no affiliates are present' do
      post :create, registration_link_params.except(:affiliate_ids)
      flash[:notice].should == 'You cannot create links without affiliates'
    end
  end
end
