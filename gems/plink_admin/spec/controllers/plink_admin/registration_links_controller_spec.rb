require 'spec_helper'

describe PlinkAdmin::RegistrationLinksController do
  let(:admin) { create_admin }
  let!(:landing_page) { create_landing_page }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    let!(:registration_link) { create_registration_link(landing_page_records: [landing_page]) }

    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'returns all registration_links' do
      assigns(:registration_links).should == [registration_link]
    end
  end

  describe 'GET new' do
    let!(:affiliate) { create_affiliate }
    let!(:campaign) { create_campaign }

    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'returns a new registration_link' do
      assigns(:registration_link).should be_present
      assigns(:registration_link).should_not be_persisted
    end

    it 'returns all affiliates' do
      assigns(:affiliates).should be_present
      assigns(:affiliates).should == [affiliate]
    end

    it 'returns all campaigns' do
      assigns(:campaigns).should be_present
      assigns(:campaigns).should == [campaign]
    end

    it 'returns all landing pages' do
      assigns(:landing_pages).should be_present
      assigns(:landing_pages).should == [landing_page]
    end

    it 'returns all share pages' do
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
        end_date: { 'end_date(1i)'=>'2013', 'end_date(2i)'=>'9', 'end_date(3i)'=>'25' },
        mobile_detection_on: true
      }
    }

    let(:registration_links) {Plink::RegistrationLinkRecord.all}
    let(:share_page) { create_share_page }

    it 'creates a registration_link_record for each affiliate_id' do
      post :create, registration_link_params

      registration_links.length.should == 2

      registration_links.first.affiliate_id.should == 134
      registration_links.last.affiliate_id.should == 123

      flash[:notice].should == 'Successfully created 2 registration link(s)'

      response.should redirect_to '/registration_links'
    end

    it 'sets the campaign_id to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:campaign_id).uniq.should == [2]
    end

    it 'sets is_active to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:is_active).uniq.should == [true]
    end

    it 'sets the start_date to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:start_date).uniq.should == [Time.zone.local(2013, 9, 23)]
    end

    it 'sets the end_date to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:end_date).uniq.should == [Time.zone.local(2013, 9, 25)]
    end

    it 'sets the mobile_detection_on to the same for all created registration_links' do
      post :create, registration_link_params

      registration_links.map(&:mobile_detection_on).uniq.should == [true]
    end

    it 'creates groupings of landing pages for each link' do
      post :create, registration_link_params

      registration_links.first.landing_page_records.should == [first_landing_page, second_landing_page]
      registration_links.last.landing_page_records.should == [first_landing_page, second_landing_page]
    end

    it 'sets a flash error and re-renders the new form if no affiliates are present' do
      post :create, registration_link_params.except(:affiliate_ids)

      flash[:notice].should == 'Failed to create any registration links'
      response.should render_template :new
    end

    context 'without landing pages' do
      before { post :create, registration_link_params.except(:landing_page_ids) }

      it 'returns an errors object' do
        assigns(:error).should be_present
      end

      it 'set a flash notice' do
        flash[:notice].should == 'Failed to create one or more registration links'
      end

      it 're-renders the form' do
        response.should render_template :new
      end
    end

    context 'with landing pages' do
      before { post :create, registration_link_params }

      it 'sets a success flash message' do
        flash[:notice].should == 'Successfully created 2 registration link(s)'
      end

      it 'redirects to the registration links index page' do
        response.should redirect_to '/registration_links'
      end
    end

    context 'without share pages' do
      before do
        post :create, registration_link_params.merge({
          share_flow: 'true'
        })
      end

      it 'returns an errors object' do
        assigns(:error).should be_present
      end

      it 'set a flash notice' do
        flash[:notice].should == 'Failed to create one or more registration links'
      end

      it 're-renders the form' do
        response.should render_template :new
      end
    end

    context 'with share pages' do
      before do
        post :create, registration_link_params.merge({
          share_flow: 'true',
          share_page_ids: [share_page.id]
        })
       end

      it 'sets a success flash message' do
        flash[:notice].should == 'Successfully created 2 registration link(s)'
      end

      it 'redirects to the registration links index page' do
        response.should redirect_to '/registration_links'
      end
    end
  end

  describe 'GET edit' do
    let!(:registration_link) { create_registration_link(landing_page_records: [landing_page]) }
    let!(:landing_page) { create_landing_page }

    before { get :edit, {id: registration_link.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'returns the registration_link by id' do
      assigns(:registration_link).should == registration_link
    end

    it 'returns all landing pages' do
      assigns(:landing_pages).should be_present
      assigns(:landing_pages).should == [landing_page]
    end
  end

  describe 'PUT update' do
    let(:first_landing_page) { create_landing_page }
    let(:second_landing_page) { create_landing_page }
    let(:registration_link) {
      create_registration_link(
        affiliate_id: 44,
        campaign_id: 45,
        end_date: 1.day.from_now,
        is_active: true,
        landing_page_records: [first_landing_page],
        mobile_detection_on: true,
        start_date: 1.day.ago
      )
    }
    let!(:registration_link_update_params) {
      {
        id: registration_link.id,
        is_active: false,
        landing_page_ids:[first_landing_page.id, second_landing_page.id],
        mobile_detection_on: false,
        start_date: { 'start_date(1i)'=>'2013', 'start_date(2i)'=>'9', 'start_date(3i)'=>'23' },
        end_date: { 'end_date(1i)'=>'2013', 'end_date(2i)'=>'9', 'end_date(3i)'=>'25' }
      }
    }
    let(:share_page) { create_share_page }

    it 'updates the record and redirects to the index' do
      put :update, registration_link_update_params

      registration_link.reload
      registration_link.is_active.should be_false
      registration_link.landing_page_records.should == [first_landing_page, second_landing_page]
      registration_link.start_date.should == Time.zone.local(2013, 9, 23)
      registration_link.end_date.should == Time.zone.local(2013, 9, 25)
      registration_link.mobile_detection_on.should be_false

      flash[:notice].should == 'Registration link updated'
      response.should redirect_to '/registration_links'
    end

    it 'updates a share_flows record and redirects the user to the index' do
      params = registration_link_update_params.merge({
        share_flow: 'true',
        share_page_ids: [share_page]
      })

      put :update, params

      flash[:notice].should == 'Registration link updated'
      response.should redirect_to '/registration_links'
    end

    it 'does not update the affiliate_id or campaign_id' do
      put :update, registration_link_update_params.merge(affiliate_id: 30, campaign_id: 31)

      registration_link.reload
      registration_link.affiliate_id.should == 44
      registration_link.campaign_id.should == 45
    end

    it 'renders the edit form when the record cannot be updated' do
      Plink::RegistrationLinkRecord.any_instance.should_receive(:update_attributes).and_return(false)

      put :update, registration_link_update_params

      flash[:notice].should == 'Could not update registration link'
      response.should render_template :edit
    end

    it 'returns errors when the record cannot be updated' do
      put :update, registration_link_update_params.except(:landing_page_ids)

      assigns(:error).should_not be_blank
    end
  end
end
