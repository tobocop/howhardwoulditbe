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

  context 'active offers' do
    before :each do
      @expected_offer = create_offer
      @expected_offers_virtual_currency = create_offers_virtual_currency(offer_id: @expected_offer.id, virtual_currency_id: 123)

      inactive_offer = create_offer(show_on_wall: false)
      create_offers_virtual_currency(offer_id: inactive_offer.id)

      inactive_offer = create_offer(is_active: false)
      create_offers_virtual_currency(offer_id: inactive_offer.id)

      inactive_offer = create_offer(start_date: 1.day.from_now)
      create_offers_virtual_currency(offer_id: inactive_offer.id)

      inactive_offer = create_offer(end_date: 1.day.ago)
      create_offers_virtual_currency(offer_id: inactive_offer.id)
    end

    describe '.active_offer' do
      it 'returns an offer_record if an active_offer exists for the offers_virtual_currency_record' do
        offers_virtual_currency_records = Plink::OffersVirtualCurrencyRecord.all
        grouped_offers_virtual_currency_records = offers_virtual_currency_records.map(&:active_offer).group_by {|elem| elem }
        grouped_offers_virtual_currency_records[nil].length.should == 4
      end
    end

    describe '.for_currency_id_with_active_offers' do
      it 'returns offers_virtual_currency records based on a currency_id if it has an active_offer' do
        offers_virtual_currency_records = Plink::OffersVirtualCurrencyRecord.for_currency_id_with_active_offers(123)
        offers_virtual_currency_records.length.should == 1
        offers_virtual_currency_records.first.id.should == @expected_offers_virtual_currency.id
      end
    end
  end

  describe '.for_currency_id' do
    before :each do
      @expected_offers_virtual_currency = create_offers_virtual_currency(virtual_currency_id: 123)
      create_offers_virtual_currency(virtual_currency_id: 456)
    end

    it 'returns offers_virtual_currency records based on a currency_id' do
      offers_virtual_currency_records = Plink::OffersVirtualCurrencyRecord.for_currency_id(123)
      offers_virtual_currency_records.length.should == 1
      offers_virtual_currency_records.first.id.should == @expected_offers_virtual_currency.id
    end
  end
end
