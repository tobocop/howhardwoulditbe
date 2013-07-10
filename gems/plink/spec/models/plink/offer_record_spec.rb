require 'spec_helper'

describe Plink::OfferRecord do
  let(:valid_attributes) {
    {
        advertiser_name: 'Gap',
        advertiser_id: 0,
        advertisers_rev_share: 0.5,
        detail_text: 'awesome text',
        start_date: '1900-01-01',
        end_date: '2999-12-31',
        is_active: true,
        show_on_wall: true
    }
  }

  subject { new_offer(valid_attributes) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be valid' do
    new_offer(valid_attributes).should be_valid
  end

  it 'provides a better interface for legacy db column names' do
    offer = new_offer(valid_attributes)

    offer.advertiser_name.should == 'Gap'
    offer.detail_text.should == 'awesome text'
  end

  it 'returns the advertisers_rev_share' do
    subject.advertisers_rev_share.should == 0.5
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

  describe 'in_wallet' do
    it 'returns all offers in a given wallet' do
      wallet = create_wallet

      plink_points_offer = create_offer
      swag_bucks_offer = create_offer
      another_plink_points_offer = create_offer

      plink_points_offer_currency = create_offers_virtual_currency(offer_id: plink_points_offer.id)
      plink_points_second_offer_currency = create_offers_virtual_currency(offer_id: another_plink_points_offer.id)
      unselected_offer = create_offers_virtual_currency(offer_id: create_offer.id)
      swag_bucks = create_offers_virtual_currency(offer_id: swag_bucks_offer.id)

      different_wallet_different_offer_vc_different_offer = create_populated_wallet_item(wallet_id: create_wallet.id, offers_virtual_currency_id: swag_bucks.id)
      different_wallet_same_offer_vc_same_offer = create_populated_wallet_item(wallet_id: create_wallet.id, offers_virtual_currency_id: unselected_offer.id)
      same_wallet_different_offer_vc_different_offer = create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: plink_points_second_offer_currency.id)
      same_wallet_same_offer_vc_same_offer      = create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: plink_points_offer_currency.id)


      Plink::OfferRecord.in_wallet(wallet.id).should =~ [plink_points_offer, another_plink_points_offer]
    end
  end

  describe 'active_virtual_currencies' do
    before :each do
      @offer = create_offer(advertiser_id: 1)
      @expected_virtual_currency = create_virtual_currency
      create_offers_virtual_currency(virtual_currency_id: @expected_virtual_currency.id, is_active: false, offer_id: @offer.id)
      create_offers_virtual_currency(virtual_currency_id: @expected_virtual_currency.id, is_active: true, offer_id: @offer.id)
    end

    it 'returns only active offers_virtual_currency records' do
      @offer.active_virtual_currencies.should == [@expected_virtual_currency]
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

      second_offers_virtual_currency = create_offers_virtual_currency(virtual_currency_id: 6, is_active: false, offer_id: @offer.id)
      @tier_for_other_virtual_currency = create_tier(offers_virtual_currency_id: second_offers_virtual_currency.id, is_active: true, start_date: Date.yesterday, end_date: Date.tomorrow)
    end

    it 'returns only the live tier records' do
      @offer.live_tiers.should == [@expected_tier, @tier_for_other_virtual_currency]
    end

    describe 'for a specific virtual currency' do
      it 'returns only the tiers for that currency' do
        @offer.live_tiers.for_virtual_currency(3).should == [@expected_tier]
      end
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

  describe 'live_only' do
    it 'returns an offer by id only if it is active, visible on the wall and for today' do
      expected_offer = create_offer(valid_attributes.merge(start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true))
      Plink::OfferRecord.live_only(expected_offer.id).should == expected_offer
    end

    it 'does not return an offer that is not shown on the wall' do
      hidden_offer = create_offer(valid_attributes.merge(show_on_wall: false))
      expect { Plink::OfferRecord.live_only(hidden_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not return an inactive offer' do
      inactive_offer = create_offer(valid_attributes.merge(is_active: false))
      expect { Plink::OfferRecord.live_only(inactive_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not return old offers' do
      old_offer = create_offer(valid_attributes.merge(end_date: Date.yesterday))
      expect { Plink::OfferRecord.live_only(old_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not return offers than have not started yet' do
      unstarted_offer = create_offer(valid_attributes.merge(start_date: Date.tomorrow))
      expect { Plink::OfferRecord.live_only(unstarted_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
