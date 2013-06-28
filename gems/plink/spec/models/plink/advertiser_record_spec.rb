require 'spec_helper'

describe Plink::AdvertiserRecord do

  let(:valid_params) {
      {
          advertiser_name: 'nervy',
          logo_url: 'nerves.jpg'
      }
  }

  subject { Plink::AdvertiserRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be valid' do
    create_advertiser(valid_params).should be_valid
  end

  it 'can return advertiser name' do
    advertiser = new_advertiser(valid_params)

    advertiser.advertiser_name.should == 'nervy'
    advertiser.logo_url.should == 'nerves.jpg'
  end
end