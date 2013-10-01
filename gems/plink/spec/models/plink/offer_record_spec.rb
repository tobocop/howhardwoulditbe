require 'spec_helper'

describe Plink::OfferRecord do
  it { should allow_mass_assignment_of(:advertiser_name) }
  it { should allow_mass_assignment_of(:advertiser_id) }
  it { should allow_mass_assignment_of(:advertisers_rev_share) }
  it { should allow_mass_assignment_of(:detail_text) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:start_date) }

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

  describe '.active_offers_virtual_currencies' do
    before :each do
      @offer = create_offer(advertiser_id: 1)
      create_offers_virtual_currency(virtual_currency_id: 3, is_active: false, offer_id: @offer.id)
      @expected_ovc = create_offers_virtual_currency(virtual_currency_id: 3, is_active: true, offer_id: @offer.id)
    end

    it 'returns only active offers_virtual_currency records' do
      @offer.active_offers_virtual_currencies.should == [@expected_ovc]
    end
  end

  context 'excluded offers' do
    let(:excluded_wallet_record) { create_wallet(user_id: 1) }
    let(:not_excluded_wallet_record) { create_wallet(user_id: 9) }

    before :each do
      gap = create_advertiser(advertiser_name: 'Gap')
      create_offer(
        advertiser_id: gap.id,
        offers_virtual_currencies: [
          new_offers_virtual_currency(
            virtual_currency_id: 54,
            tiers: [
              new_tier
            ]
          )
        ]
      )

      not_gap = create_advertiser(advertiser_name: 'Not Gap')
      @expected_offer = create_offer(
        advertiser_id: not_gap.id,
        offers_virtual_currencies: [
          new_offers_virtual_currency(
            virtual_currency_id: 54,
            tiers: [
              new_tier
            ]
          )
        ]
      )

      expired_offer = create_offer(
        advertiser_id: not_gap.id,
        offers_virtual_currencies: [
          new_offers_virtual_currency(
            is_active: false,
            virtual_currency_id: 54,
            tiers: [
              new_tier
            ]
          )
        ]
      )
    end

    describe '.live_non_excluded_offers_for_currency' do
      it 'returns live offers that are excluded from a wallet' do
        offers = Plink::OfferRecord.live_non_excluded_offers_for_currency(excluded_wallet_record.id, 54)
        offers.length.should == 1
        offers.first.id.should == @expected_offer.id
      end

      it 'returns live offers that are not excluded from a wallet' do
        offers = Plink::OfferRecord.live_non_excluded_offers_for_currency(not_excluded_wallet_record.id, 54)
        offers.length.should == 2
      end
    end

    describe '.non_excluded_offers' do
      it 'returns offers that are not excluded from a wallet' do
        offers = Plink::OfferRecord.non_excluded_offers(excluded_wallet_record.id)
        offers.length.should == 2
      end
    end
  end

  describe '.in_wallet' do
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

  describe '.active_virtual_currencies' do
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

  describe '.live_tiers' do
    before :each do
      @offer = create_offer(advertiser_id: 1)

      offers_virtual_currency = create_offers_virtual_currency(virtual_currency_id: 3, is_active: false, offer_id: @offer.id)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: false)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, start_date: 1.day.from_now)
      create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, end_date: 1.day.ago)
      @expected_tier = create_tier(offers_virtual_currency_id: offers_virtual_currency.id, is_active: true, start_date: 1.day.ago, end_date: 1.day.from_now)

      second_offers_virtual_currency = create_offers_virtual_currency(virtual_currency_id: 6, is_active: false, offer_id: @offer.id)
      @tier_for_other_virtual_currency = create_tier(offers_virtual_currency_id: second_offers_virtual_currency.id, is_active: true, start_date: 1.day.ago, end_date: 1.day.from_now)
    end

    it 'returns only the live tier records' do
      @offer.live_tiers.should == [@expected_tier, @tier_for_other_virtual_currency]
    end

    context 'for a specific virtual currency' do
      it 'returns only the tiers for that currency' do
        @offer.live_tiers.for_virtual_currency(3).should == [@expected_tier]
      end
    end
  end

  describe '.live_offers_for_currency' do
    before :each do
      create_offer(valid_attributes.merge(
        show_on_wall: false, 
        offers_virtual_currencies: [
          create_offers_virtual_currency(virtual_currency_id: 13, tiers: [new_tier, new_tier])
      ]))

      offer_with_other_virtual_currency = create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 123,
              tiers: [new_tier]
          )
      ]))

      create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              is_active: false,
              virtual_currency_id: 13,
              tiers: [new_tier]
          )
      ]))

      @second_offer = create_offer(valid_attributes.merge(detail_text: 'older new one', start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, is_new: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 13,
              tiers: [new_tier, new_tier]
          )
      ]))

      @first_offer = create_offer(valid_attributes.merge(detail_text: 'newer new one', start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, is_new: true, show_on_wall: true, offers_virtual_currencies: [
          create_offers_virtual_currency(
              virtual_currency_id: 13,
              tiers: [new_tier, new_tier]
          ),
          create_offers_virtual_currency(
              virtual_currency_id: 37846,
              tiers: [new_tier]
          )
      ]))

      @third_offer = create_offer(valid_attributes.merge(detail_text: 'no active tiers', start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        create_offers_virtual_currency(
          virtual_currency_id: 13,
          tiers: [new_tier(is_active:false)]
        )
      ]))
    end

    it 'returns offers only live offers for the given currency and also offers with no active tiers (for simplicity), ordered by is_new then created_at DESC' do
      ordered_offers = [@first_offer, @second_offer, @third_offer]
      offers = Plink::OfferRecord.live_offers_for_currency(13)
      offers.should == ordered_offers
      offers.first.active_offers_virtual_currencies.length.should == 1
    end
  end

  describe '.for_currency_id' do
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

  describe '.active' do
    before do
      @offer1 = create_offer(valid_attributes)
      @offer2 = create_offer(valid_attributes.merge(is_active: false))
    end

    it 'returns only offers that are active' do
      Plink::OfferRecord.active.should == [@offer1]
    end
  end

  describe '.visible_on_wall' do
    before do
      @offer1 = create_offer(valid_attributes.merge(show_on_wall: false))
      @offer2 = create_offer(valid_attributes)
    end

    it 'returns offers that have showOnWall = true' do
      Plink::OfferRecord.visible_on_wall.should == [@offer2]
    end
  end

  describe '.for_today' do
    before do
      @offer1 = create_offer(valid_attributes.merge(start_date: 1.day.from_now))
      @offer2 = create_offer(valid_attributes.merge(end_date: 1.day.ago))
      @offer3 = create_offer(valid_attributes.merge(start_date: 3.days.ago, end_date: 1.day.ago))
      @offer4 = create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now))
    end

    it 'returns offers between the start and end date' do
      Plink::OfferRecord.for_today.should == [@offer4]
    end
  end

  describe '.live' do
    before do
      create_offer(valid_attributes.merge(show_on_wall: false))
      create_offer(valid_attributes.merge(is_active: false))
      create_offer(valid_attributes.merge(start_date: 1.day.from_now))
      create_offer(valid_attributes.merge(end_date: 1.day.ago))
      create_offer(valid_attributes.merge(start_date: 3.days.ago, end_date: 1.day.ago))
      create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, show_on_wall: false))
      create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, is_active: false))
      @expected_offer = create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, show_on_wall: true))
    end

    it 'returns only offers that are active, visible on the wall and for today' do
      Plink::OfferRecord.live.should == [@expected_offer]
    end
  end

  describe '.live_only' do
    it 'returns an offer by id only if it is active, visible on the wall and for today' do
      expected_offer = create_offer(valid_attributes.merge(start_date: 1.day.ago, end_date: 1.day.from_now, is_active: true, show_on_wall: true))
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
      old_offer = create_offer(valid_attributes.merge(end_date: 1.day.ago))
      expect { Plink::OfferRecord.live_only(old_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'does not return offers than have not started yet' do
      unstarted_offer = create_offer(valid_attributes.merge(start_date: 1.day.from_now))
      expect { Plink::OfferRecord.live_only(unstarted_offer.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
