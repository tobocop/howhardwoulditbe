require 'spec_helper'

describe Plink::OfferRecord do
  let(:valid_attributes) {
    {
        advertiser_name: 'Gap',
        advertiser_id: 0,
        advertisers_rev_share: 0,
        detail_text: 'awesome text',
        start_date: '1900-01-01'
    }
  }

  it 'can be valid' do
    new_offer(valid_attributes).should be_valid
  end

  it 'provides a better interface for legacy db column names' do
    offer = new_offer(valid_attributes)

    offer.advertiser_name.should == 'Gap'
    offer.detail_text.should == 'awesome text'
  end
end
