require 'spec_helper'

describe 'memolink:convert_to_all_offers', skip_in_build: true do
  include_context 'rake'

  let(:virtual_currency) { create_virtual_currency(name: 'memolink points', subdomain: 'memolink', has_all_offers:false, exchange_rate: 1600) }
  before :each do

    quiznos = create_advertiser(advertiser_name: 'Quiznos')
    @quiznos_offer = create_offer(advertisers_rev_share: 0.08, advertiser_id: quiznos.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    outback_steakhouse = create_advertiser(advertiser_name: 'Outback Steakhouse')
    @outback_steakhouse_offer = create_offer(advertisers_rev_share: 0.10,advertiser_id: outback_steakhouse.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    seven_eleven = create_advertiser(advertiser_name: '7 - Eleven')
    @seven_eleven_offer = create_offer(advertisers_rev_share: 0.05,advertiser_id: seven_eleven.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    red_robin = create_advertiser(advertiser_name: 'Red Robin')
    @red_robin_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: red_robin.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    dunkin_donuts = create_advertiser(advertiser_name: "Dunkin' Donuts")
    @dunkin_donuts_offer = create_offer(advertisers_rev_share: 0.02,advertiser_id: dunkin_donuts.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    burger_king = create_advertiser(advertiser_name: 'Burger King')
    @burger_king_offer = create_offer(advertisers_rev_share: 0.05,advertiser_id: burger_king.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    regal_cinemas = create_advertiser(advertiser_name: 'Regal Cinemas')
    @regal_cinemas_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: regal_cinemas.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    edwards_theatres = create_advertiser(advertiser_name: 'Edwards Theatres')
    @edwards_theatres_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: edwards_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    united_artists_theatres = create_advertiser(advertiser_name: 'United Artists Theatres')
    @united_artists_theatres_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: united_artists_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    gap = create_advertiser(advertiser_name: 'Gap')
    @gap_offer = create_offer(advertisers_rev_share: 0.1,advertiser_id: gap.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    old_navy = create_advertiser(advertiser_name: 'Old Navy')
    @old_navy_offer = create_offer(advertisers_rev_share: 0.1,advertiser_id: old_navy.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    kmart = create_advertiser(advertiser_name: 'Kmart')
    @kmart_offer = create_offer(advertisers_rev_share: 0.05,advertiser_id: kmart.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    sears = create_advertiser(advertiser_name: 'Sears')
    @sears_offer = create_offer(advertisers_rev_share: 0.05,advertiser_id: sears.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    dollar_general = create_advertiser(advertiser_name: 'Dollar General')
    @dollar_general_offer = create_offer(advertisers_rev_share: 0.03,advertiser_id: dollar_general.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    champs_sports = create_advertiser(advertiser_name: 'Champs Sports')
    @champs_sports_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: champs_sports.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    eastbay_ccs = create_advertiser(advertiser_name: 'Eastbay/CCS')
    @eastbay_ccs_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: eastbay_ccs.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    footaction = create_advertiser(advertiser_name: 'Footaction')
    @footaction_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: footaction.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    foot_locker = create_advertiser(advertiser_name: 'Foot Locker')
    @foot_locker_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: foot_locker.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    puritans_pride = create_advertiser(advertiser_name: "Puritan's Pride")
    @puritans_pride_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: puritans_pride.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    vitamin_world = create_advertiser(advertiser_name: 'Vitamin World')
    @vitamin_world_offer = create_offer(advertisers_rev_share: 0.08,advertiser_id: vitamin_world.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
  end

  it 'sets the virtual currency to has_all_offers to true' do
    pre_memolink_virtual_currency = Plink::VirtualCurrency.find_by_sudomain('memolink').first
    pre_memolink_virtual_currency.has_all_offers.should be_false

    subject.invoke

    post_memolink_virtual_currency = Plink::VirtualCurrency.find_by_sudomain('memolink').first
    post_memolink_virtual_currency.has_all_offers.should be_true
  end

  it 'inserts new tiers for percentage based awards and expires old tiers' do
    subject.invoke

    tiers = @quiznos_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    tier.percent_award_amount.should == 2.4
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @outback_steakhouse_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 48

    tiers = @seven_eleven_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 24

    tiers = @red_robin_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @dunkin_donuts_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 9

    tiers = @burger_king_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 24

    tiers = @regal_cinemas_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @edwards_theatres_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @united_artists_theatres_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @gap_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 48

    tiers = @old_navy_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 48

    tiers = @kmart_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 24

    tiers = @sears_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 24

    tiers = @dollar_general_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 14

    tiers = @champs_sports_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @eastbay_ccs_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @footaction_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @foot_locker_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @puritans_pride_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38

    tiers = @vitamin_world_offer.reload.live_tiers.for_virtual_currency(virtual_currency.id)
    tiers.length.should == 1
    tier = tiers.first
    tier.minimum_purchase_amount.should == 0.01
    (tier.percent_award_amount / 100 * virtual_currency.exchange_rate).to_i.should == 38
  end

end
