require 'spec_helper'

describe SharePagesController do
  let(:share_page) {  double(Plink::SharePageRecord, id: 12, persisted?: true) }
  let(:user) { set_current_user }

  before { set_virtual_currency(currency_name: 'Bit Bucks', amount_in_currency: 24) }

  describe 'GET show' do
    before do
      Plink::SharePageRecord.stub(:find).and_return(share_page)
      get :show, id: share_page.id
    end

    it 'should be successful' do
      response.should be_success
    end

    it 'sets @user' do
      assigns(:user).should_not be_nil
    end

    it 'sets @affiliate_id' do
      assigns(:affiliate_id).should be_instance_of Fixnum
    end

    it 'sets @share_page' do
      assigns(:share_page).should_not be_nil
    end
  end

  describe 'GET create_share_tracking_record' do
    before do
      session[:registration_link_id] = 1
      session[:share_page_id] = 1
    end

    it 'responds sucessfully' do
      get :create_share_tracking_record, id: share_page.id

      response.should be_success
    end

    it 'records that the user saw the page' do
      Plink::SharePageTrackingRecord.should_receive(:where).
        with(registration_link_id: 1, share_page_id: share_page.id.to_s, user_id: user.id).
        and_return(double(first_or_create: share_page))#.

      get :create_share_tracking_record, id: share_page.id
    end

    it 'sends errors to Exceptional in production' do
      module Exceptional ; class Catcher ; end ; end

      Rails.env.stub(:production?).and_return(true)
      error_stub = double(full_messages: Array('Something went wrong'))
      Plink::SharePageTrackingRecord.stub_chain(:where, :first_or_create).
        and_return(double(persisted?: false, errors: error_stub))

      Exceptional::Catcher.should_receive(:handle)

      get :create_share_tracking_record, id: share_page.id
    end

    it 'should render nothing' do
      get :create_share_tracking_record, id: share_page.id

      response.should render_template nil
    end
  end

  describe 'GET update_share_tracking_record' do
    before do
      session[:registration_link_id] = 1
      session[:share_page_id] = 1
    end

    it 'responds sucessfully' do
      get :update_share_tracking_record, id: share_page.id

      response.should be_success
    end

    it 'records that the user declined to share' do
      controller.stub(:first_or_create).and_return(share_page)

      share_page.should_receive(:update_attributes).with(shared: false)

      get :update_share_tracking_record, id: share_page.id, shared: false.to_s
    end

    it 'records that the user shared' do
      controller.stub(:first_or_create).and_return(share_page)

      share_page.should_receive(:update_attributes).with(shared: true)

      get :update_share_tracking_record, id: share_page.id, shared: true.to_s
    end

    it 'sends errors to Exceptional in production' do
      module Exceptional ; class Catcher ; end ; end

      Rails.env.stub(:production?).and_return(true)
      error_stub = double(full_messages: Array('Something went wrong'))
      Plink::SharePageTrackingRecord.stub_chain(:where, :first_or_create).
        and_return(double(update_attributes: false, errors: error_stub))

      Exceptional::Catcher.should_receive(:handle)

      get :update_share_tracking_record, id: share_page.id
    end

    it 'should render nothing' do
      get :create_share_tracking_record, id: share_page.id

      response.should render_template nil
    end
  end
end
