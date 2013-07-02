require 'spec_helper'

describe Plink::OffersVirtualCurrencyRecord do

  let(:valid_params) {
    {
        offer_id: 143,
        virtual_currency_id: 34
    }
  }

  subject { Plink::OffersVirtualCurrencyRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be valid' do
    create_offers_virtual_currency(valid_params).should be_valid
  end

  it 'can return detail text' do
    ovc = new_offers_virtual_currency(valid_params.merge(detail_text: 'new text'))
    ovc.detail_text.should == 'new text'
  end

  it 'has a virtual currency' do
    vc = create_virtual_currency
    ovc = new_offers_virtual_currency(valid_params.merge(detail_text: 'new text', virtual_currency: vc))
    ovc.virtual_currency.should == vc
  end

  it 'has a virtual currency id' do
    ovc = new_offers_virtual_currency(valid_params.merge(detail_text: 'new text', virtual_currency_id: 123))
    ovc.virtual_currency_id.should == 123
  end

  it 'has a virtual currency' do
    offer = create_offer
    ovc = new_offers_virtual_currency(valid_params.merge(detail_text: 'new text', offer: offer))
    ovc.offer.should == offer
  end
end