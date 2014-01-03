require 'spec_helper'

describe TrackingController do
  it_should_behave_like(:tracking_extensions)

  describe 'GET new' do
    let(:valid_options) { {
      'aid' => '1732',
      'c' => 'BIGLONGHASH',
      'campaign_id' => nil,
      'pathID' => '123',
      'subID' => 'Subid 1',
      'subID2' => 'Subid 2',
      'subID3' => 'Subid 3',
      'subID4' => 'Subid 4'
    }}


    it 'can be successful' do
      get :new
      response.should redirect_to root_path
    end

    it 'stores url variables into a structured hash in the session' do
      tracking_hash = {affiliate_id: '1732'}
      hash_stub = double(to_hash: tracking_hash)
      TrackingObject.should_receive(:from_params).with(valid_options).and_return { hash_stub }
      get :new, aid: 1732, subID: 'Subid 1', subID2: 'Subid 2', subID3: 'Subid 3', subID4: 'Subid 4', pathID: '123', c: 'BIGLONGHASH'
      session[:tracking_params].should == tracking_hash
    end

    it 'redirects to a given url if present in the params' do
      get :new, redirect_user_to: wallet_path
      response.should redirect_to wallet_path
    end
  end

  describe 'GET hero_promotion_click' do
    before do
      set_current_user({id: 134})
      set_virtual_currency
   end

    it 'is non-blocking with an invalid request' do
      get :hero_promotion_click

      response.should be_success
    end

    it 'requires an authenticated user' do
      controller.should_receive(:require_authentication)

      get :hero_promotion_click
    end

    it 'creates a HeroPromotionClick record' do
      Plink::HeroPromotionClickRecord.should_receive(:create).
        with(
          hero_promotion_id: '1',
          image: 'http://googlez.forshizzle/mynizzle',
          user_id: 134
        )

      get :hero_promotion_click, hero_promotion_id: 1, image: 'http://googlez.forshizzle/mynizzle'
    end
  end
end
