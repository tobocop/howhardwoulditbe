require 'spec_helper'

describe TrackingObject do
  let(:valid_options) { {
    'aid' => '1732',
    'subID' => 'Subid 1',
    'subID2' => 'Subid 2',
    'subID3' => 'Subid 3',
    'subID4' => 'Subid 4',
    'pathID' => '123',
    'c' => 'BIGLONGHASH',
    'campaign_id' => 234
  }}

  describe '.new' do
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
      tracking_object.campaign_id.should == 234
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
      tracking_object.campaign_id.should == nil
    end
  end

  describe '.to_hash' do
    it 'can build a hash of proper tracking params based on a hash' do
      my_hash = TrackingObject.from_params(valid_options).to_hash
      my_hash[:affiliate_id].should == '1732'
      my_hash[:sub_id].should == 'Subid 1'
      my_hash[:sub_id_two].should == 'Subid 2'
      my_hash[:sub_id_three].should == 'Subid 3'
      my_hash[:sub_id_four].should == 'Subid 4'
      my_hash[:path_id].should == '123'
      my_hash[:campaign_hash].should == 'BIGLONGHASH'
      my_hash[:campaign_id].should == 234
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
      my_hash[:campaign_id].should == nil
    end
  end

  describe '.steelhouse_additional_info' do
    it 'generates the additional info string for a steelhouse pixel' do
      steelhouse_additional_info = TrackingObject.from_params(valid_options).steelhouse_additional_info(123)
      steelhouse_additional_info.should == '&affiliateid=1732,&subid=subid 1,&subid2=subid 2,&subid3=subid 3,&subid4=subid 4,&campaignid=234,&pathid=123,&virtualcurrencyid=123,'
    end

    it 'generates the additional info string for a steelhouse pixel without valid_options' do
      steelhouse_additional_info = TrackingObject.from_params({}).steelhouse_additional_info(123)
      steelhouse_additional_info.should == '&affiliateid=1,&subid=,&subid2=,&subid3=,&subid4=,&campaignid=,&pathid=1,&virtualcurrencyid=123,'
    end
  end

end
