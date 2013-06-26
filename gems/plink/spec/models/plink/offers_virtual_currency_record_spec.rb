require 'spec_helper'

describe Plink::OffersVirtualCurrencyRecord do

  let(:valid_params) {
    {
        offer_id: 143,
        virtual_currency_id: 34
    }
  }
  it 'can be valid' do
    create_offers_virtual_currency(valid_params).should be_valid
  end

  it 'can return detail text' do
    ovc = new_offers_virtual_currency(valid_params.merge(detail_text: 'new text'))
    ovc.detail_text.should == 'new text'
  end

end