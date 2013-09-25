require 'spec_helper'
require 'digest/sha1'

describe PlinkAdmin::CampaignsController do
  let(:admin) { create_admin }
  let!(:campaign) { create_campaign(
    name: 'my campaign'
  )}

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all campaigns in the database' do
      assigns(:campaigns).should == [campaign]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new campaign' do
      assigns(:campaign).should be_present
      assigns(:campaign).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a campaign record and redirects to the listing when successful' do
      campaign_params = {
        name: 'Here we go',
      }

      post :create, {campaign: campaign_params}
      campaign = Plink::CampaignRecord.last
      campaign.name.should == 'Here we go'
      campaign.campaign_hash.should == Digest::SHA1.hexdigest(campaign.name)

      response.should redirect_to '/campaigns'
    end

    it 're-renders the new form when the record cannot be persisted' do
      create_params = {
         'name' => 'created name',
         'campaign_hash' => Digest::SHA1.hexdigest('created name')
      }

      Plink::CampaignRecord.should_receive(:create).with(create_params).and_return(double(persisted?: false))

      post :create, {campaign: {name: 'created name'}}

      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: campaign.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the campaign by id' do
      assigns(:campaign).should == campaign
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: campaign.id, campaign: {name: 'updated name'}}
      campaign.reload.name.should == 'updated name'
      response.should redirect_to '/campaigns'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::CampaignRecord.should_receive(:find).with(campaign.id.to_s).and_return(campaign)
      campaign.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: campaign.id, campaign: {name: 'updated name'}}

      response.should render_template 'edit'
    end
  end
end
