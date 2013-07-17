require 'spec_helper'

describe TrackingController do
  describe 'index' do
    let(:valid_options) { {
      'aid' => '1732',
      'subID' => 'Subid 1',
      'subID2' => 'Subid 2',
      'subID3' => 'Subid 3',
      'subID4' => 'Subid 4',
      'pathID' => '123',
      'c' => 'BIGLONGHASH'
    }}


    it 'can be successful' do
      get :new
      response.should redirect_to root_path
    end

    it 'stores url variables into a structured hash in the session' do
      tracking_hash = {affiliate_id: '1732'}
      hash_stub = stub(to_hash: tracking_hash)
      TrackingObject.should_receive(:from_params).with(valid_options).and_return { hash_stub }
      get :new, aid: 1732, subID: 'Subid 1', subID2: 'Subid 2', subID3: 'Subid 3', subID4: 'Subid 4', pathID: '123', c: 'BIGLONGHASH'
      session[:tracking_params].should == tracking_hash
    end

  end
end