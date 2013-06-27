require 'spec_helper'

describe Plink::OfferRecord do
  let(:valid_attributes) {
    {
        advertiser_name: 'Gap',
        advertiser_id: 0,
        advertisers_rev_share: 0,
        detail_text: 'awesome text',
        start_date: '1900-01-01',
        end_date: '2999-12-31',
        is_active: true,
        show_on_wall: true
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

  describe 'active_offers_virtual_currencies' do
    before :each do
      @offer = create_offer(advertiser_id: 1)
      create_offers_virtual_currency(virtual_currency_id: 3, is_active: false, offer_id: @offer.id)
      @expected_ovc = create_offers_virtual_currency(virtual_currency_id: 3, is_active: true, offer_id: @offer.id)
    end

    it 'returns only active offers_virtual_currency records' do
      @offer.active_offers_virtual_currencies.should == [@expected_ovc]
    end
  end

  describe 'live_tiers' do
    before :each do
      @offer = create_offer(advertiser_id: 1)
      offers_virtual_currency = create_offers_virtual_currency(virtual_currency_id: 3, is_active: false, offer_id: @offer.id)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: false)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, start_date: Date.tomorrow)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, end_date: Date.yesterday)
      @expected_tier = create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, start_date: Date.yesterday, end_date: Date.tomorrow)
    end

    it 'returns only the live tier records' do
      @offer.live_tiers.should == [@expected_tier]
    end
  end

  describe 'live_offers_for_currency' do
    before :each do
      create_offer(valid_attributes.merge(show_on_wall: false))
      create_offer(valid_attributes.merge(is_active: false))
      create_offer(valid_attributes.merge(start_date: Date.tomorrow))
      create_offer(valid_attributes.merge(end_date: Date.yesterday))
      create_offer(valid_attributes.merge(start_date: Date.yesterday - 2.days, end_date: Date.yesterday))
      create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, show_on_wall: false))
      create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: false))

      offer_with_other_virtual_currency = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 123,
              tiers: [new_tier]
          )
      ]))

      create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              is_active: false,
              virtual_currency_id: 13,
              tiers: [new_tier]
          )
      ]))

      @offer_with_no_active_tiers = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 13,
              tiers: [new_tier(is_active:false)]
          )
      ]))

      @expected_offer = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 13,
              tiers: [new_tier, new_tier]
          )
      ]))
    end

    it 'returns offers only live offers for the given currency and also offers with no active tiers (for simplicity)' do
      Plink::OfferRecord.live_offers_for_currency(13).should =~ [@expected_offer, @offer_with_no_active_tiers]
    end

  end

  describe 'for_currency_id' do
    it 'returns offers only for the given currency' do
      create_offer(
          advertiser_id: 1,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 3
              )
          ]
      )
      expected_offer = create_offer(
          advertiser_id: 1,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 54
              )
          ]
      )

      offers = Plink::OfferRecord.for_currency_id(54)
      offers.map(&:id).should == [expected_offer.id]
    end
  end

  describe 'active' do
    before do
      @offer1 = create_offer(valid_attributes)
      @offer2 = create_offer(valid_attributes.merge(is_active: false))
    end

    it 'returns only offers that are active' do
      Plink::OfferRecord.active.should == [@offer1]
    end
  end

  describe 'visible_on_wall' do
    before do
      @offer1 = create_offer(valid_attributes.merge(show_on_wall: false))
      @offer2 = create_offer(valid_attributes)
    end

    it 'returns offers that have showOnWall = true' do
      Plink::OfferRecord.visible_on_wall.should == [@offer2]
    end
  end

  describe 'for_today' do
    before do
      @offer1 = create_offer(valid_attributes.merge(start_date: Date.tomorrow))
      @offer2 = create_offer(valid_attributes.merge(end_date: Date.yesterday))
      @offer3 = create_offer(valid_attributes.merge(start_date: Date.yesterday - 2.days, end_date: Date.yesterday))
      @offer4 = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow))
    end

    it 'returns offers between the start and end date' do
      Plink::OfferRecord.for_today.should == [@offer4]
    end
  end

  describe 'live' do
    before do
      create_offer(valid_attributes.merge(show_on_wall: false))
      create_offer(valid_attributes.merge(is_active: false))
      create_offer(valid_attributes.merge(start_date: Date.tomorrow))
      create_offer(valid_attributes.merge(end_date: Date.yesterday))
      create_offer(valid_attributes.merge(start_date: Date.yesterday - 2.days, end_date: Date.yesterday))
      create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, show_on_wall: false))
      create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: false))
      @expected_offer = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true))
    end

    it 'returns only offers that are active, visible on the wall and for today' do
      Plink::OfferRecord.live.should == [@expected_offer]
    end
  end
end
