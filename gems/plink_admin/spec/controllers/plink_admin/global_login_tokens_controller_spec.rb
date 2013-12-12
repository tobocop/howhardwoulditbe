require 'spec_helper'

describe PlinkAdmin::GlobalLoginTokensController do
  let(:admin) { create_admin }
  let!(:global_login_token) { create_global_login_token(expires_at: 7.days.from_now) }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all global_login_tokens in the database' do
      assigns(:global_login_tokens).should == [global_login_token]
    end

    it 'orders tokens by the earliest expiration date' do
      older_token = create_global_login_token(expires_at: 2.days.from_now)
      assigns(:global_login_tokens).should == [older_token, global_login_token]
    end

    it 'does not return tokens expiring more then 7 days ago' do
      create_global_login_token(expires_at: 8.days.ago)
      assigns(:global_login_tokens).should == [global_login_token]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new global_login_token' do
      assigns(:global_login_token).should be_present
      assigns(:global_login_token).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a global_login_token record and redirects to the listing when successful' do
      global_login_token_params = {
        expires_at: 7.days.from_now,
        redirect_url: 'http://awesome.com'
      }

      post :create, {global_login_token: global_login_token_params}
      global_login_token = Plink::GlobalLoginTokenRecord.last
      global_login_token.expires_at.to_date.should == 7.days.from_now.to_date
      global_login_token.redirect_url.should == 'http://awesome.com'
      global_login_token.token.should_not be_nil

      flash[:notice].should == 'Global login token created successfully'

      response.should redirect_to '/global_login_tokens'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::GlobalLoginTokenRecord.stub(:create).and_return(double(persisted?: false))

      post :create, {global_login_token: {}}

      flash[:notice].should == 'Global login token could not be created'
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: global_login_token.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the global_login_token by id' do
      assigns(:global_login_token).should == global_login_token
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: global_login_token.id, global_login_token: {redirect_url: 'updated'}}

      global_login_token.reload.redirect_url.should == 'updated'
      flash[:notice].should == 'Global login token updated'
      response.should redirect_to '/global_login_tokens'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::GlobalLoginTokenRecord.should_receive(:find).with(global_login_token.id.to_s).and_return(global_login_token)
      global_login_token.should_receive(:update_attribute).with('redirect_url', 'updated').and_return(false)

      put :update, {id: global_login_token.id, global_login_token: {redirect_url: 'updated'}}

      flash[:notice].should == 'Global login token could not be updated'
      response.should render_template 'edit'
    end
  end
end
