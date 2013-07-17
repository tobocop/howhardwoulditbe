require 'spec_helper'

describe TrackingObject do
  let(:valid_options) { {
    'aid' => '1732',
    'subID' => 'Subid 1',
    'subID2' => 'Subid 2',
    'subID3' => 'Subid 3',
    'subID4' => 'Subid 4',
    'pathID' => '123',
    'c' => 'BIGLONGHASH'
  }}

  describe 'new' do
    it 'takes a hash of tracking params and stores them in the object' do
      session_hash = TrackingObject.from_params(valid_options).to_hash
      tracking_object = TrackingObject.new(session_hash.merge(ip: '175.125.35.1'))
      tracking_object.affiliate_id.should == '1732'
      tracking_object.sub_id.should == 'Subid 1'
      tracking_object.sub_id_two.should == 'Subid 2'
      tracking_object.sub_id_three.should == 'Subid 3'
      tracking_object.sub_id_four.should == 'Subid 4'
      tracking_object.path_id.should == '123'
      tracking_object.ip.should == '175.125.35.1'
    end

    it 'can be initialized with a blank hash and use defaults' do
      tracking_object = TrackingObject.new({})
      tracking_object.affiliate_id.should == '1'
      tracking_object.sub_id.should == nil
      tracking_object.sub_id_two.should == nil
      tracking_object.sub_id_three.should == nil
      tracking_object.sub_id_four.should == nil
      tracking_object.path_id.should == '1'
      tracking_object.campaign_hash.should == nil
    end
  end

  describe 'build_hash' do
    it 'can build a hash of proper tracking params based on a hash' do
      my_hash = TrackingObject.from_params(valid_options).to_hash
      my_hash[:affiliate_id].should == '1732'
      my_hash[:sub_id].should == 'Subid 1'
      my_hash[:sub_id_two].should == 'Subid 2'
      my_hash[:sub_id_three].should == 'Subid 3'
      my_hash[:sub_id_four].should == 'Subid 4'
      my_hash[:path_id].should == '123'
      my_hash[:campaign_hash].should == 'BIGLONGHASH'
    end

    it 'can build a hash without all the valid params' do
      my_hash = TrackingObject.from_params({}).to_hash
      my_hash[:affiliate_id].should == '1'
      my_hash[:sub_id].should == nil
      my_hash[:sub_id_two].should == nil
      my_hash[:sub_id_three].should == nil
      my_hash[:sub_id_four].should == nil
      my_hash[:path_id].should == '1'
      my_hash[:campaign_hash].should == nil
    end
  end

end