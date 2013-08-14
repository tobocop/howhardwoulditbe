require 'plink/test_helpers/object_creation_methods'

include Plink::ObjectCreationMethods

Plink::UserRecord.destroy_all
PlinkAdmin::Admin.destroy_all
Plink::OauthToken.destroy_all
Plink::NewsArticleRecord.destroy_all
Plink::UsersInstitutionAccountRecord.destroy_all
Plink::UserReverificationRecord.destroy_all
Plink::EventTypeRecord.destroy_all
Plink::AwardTypeRecord.destroy_all
Plink::FreeAwardRecord.destroy_all
Plink::VirtualCurrency.destroy_all
Plink::HeroPromotionRecord.destroy_all
Plink::AdvertiserRecord.destroy_all
Plink::OfferRecord.destroy_all
Plink::OffersVirtualCurrencyRecord.destroy_all
Plink::TierRecord.destroy_all
Plink::RewardRecord.destroy_all
Plink::RewardAmountRecord.destroy_all
Plink::FreeAwardRecord.destroy_all
Plink::QualifyingAwardRecord.destroy_all
Plink::NonQualifyingAwardRecord.destroy_all
Plink::RedemptionRecord.destroy_all
Plink::InstitutionRecord.destroy_all
Plink::UsersInstitutionRecord.destroy_all
Plink::WalletItemRecord.destroy_all
Plink::WalletRecord.destroy_all
Plink::UsersAwardPeriodRecord.destroy_all

p 'Creating VirtualCurrency'
virtual_currency = Plink::VirtualCurrency.create(name: "Plink points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")
memolink_virtual_currency = Plink::VirtualCurrency.create(name: "memolink points", subdomain: "memolink", exchange_rate: 1600, site_name: "Memolink", singular_name: "memolink point")

p 'Creating institution'
institution = create_institution(name: 'Bank of AMERRRICA!')
create_institution(name: 'CC Bank', intuit_institution_id: 100000)

p 'Creating Dev user'
user = create_user(password: 'password', email: 'pivotal@plink.com', avatar_thumbnail_url: 'http://img.gawkerassets.com/img/17m6znqc61o49jpg/original.jpg')
users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Linking Dev User'
users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
create_oauth_token(user_id: user.id)
create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id, name: 'Tiny checking account', account_number_last_four: 2341)

p 'Creating user that needs reverification'
user_reverify = create_user(password: 'password', email: 'reverify@plink.com')
users_virtual_currency = create_users_virtual_currency(user_id: user_reverify.id, virtual_currency_id: virtual_currency.id)
wallet = create_wallet(user_id: user_reverify.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Linking reverification user'
users_institution = create_users_institution(user_id: user_reverify.id, institution_id: institution.id)
create_oauth_token(user_id: user_reverify.id)
create_users_institution_account(user_id: user_reverify.id, users_institution_id: users_institution.id, name: 'Tiny checking account', account_number_last_four: 2341)

p 'Creating reverification'
create_user_reverification(user_id: user_reverify.id, users_institution_id: users_institution.id)


p 'Creating Admin user'
PlinkAdmin::Admin.new do |admin|
  admin.email ='pivotal@plink.com'
  admin.password = 'password'
  admin.save
end

p 'Creating HeroPromotions'
Plink::HeroPromotionRecord.create(name: 'Yo-hiness', image_url: '/assets/hero-gallery/bk_2.jpg', title: 'Get Double Points at Burger King', display_order: 1)
Plink::HeroPromotionRecord.create(name: 'Stefan', image_url: '/assets/hero-gallery/TacoBell_2.jpg', title: 'New Partner - Taco Bell', display_order: 2)
Plink::HeroPromotionRecord.create(name: 'Georg', image_url: '/assets/hero-gallery/7eleven_2.jpg', title: '7-Eleven = AMAZING HOTDOGS', display_order: 3)

p 'Creating Advertisers'
old_navy = Plink::AdvertiserRecord.create(advertiser_name: 'Old Navy', logo_url: '/assets/wallet-logos/oldnavy.png')
arbys = Plink::AdvertiserRecord.create(advertiser_name: 'Arbys', logo_url: '/assets/wallet-logos/arbys.png')
burger_king = Plink::AdvertiserRecord.create(advertiser_name: 'Burger King', logo_url: '/assets/wallet-logos/bk-cropped.png')
gap = Plink::AdvertiserRecord.create(advertiser_name: 'Gap', logo_url: '/assets/wallet-logos/gap.png')

p 'Creating Offers'
create_offer(advertiser_id: old_navy.id, start_date: '1900-01-01', offers_virtual_currencies: [
  new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [
    new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'),
    new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 10, end_date: '2999-12-31'),
    new_tier(dollar_award_amount: 10.5, minimum_purchase_amount: 100, end_date: '2999-12-31')
  ]
  )
]
)

create_offer(advertiser_id: arbys.id,
             start_date: '1900-01-01',
             detail_text: %Q{<p class="font13pt"> Arby's&reg; is the place for people hungering for a unique , better tasting alternative to traditional fast food.Serving one-of-a-kind menu items, Arby's is well known for slow-roasted and freshly sliced Roast Beef sandwiches, Curly Fries, and Jamocha Shakes.</p><p class="font13pt mvm"> Earn $vc_dollarAmount$ for any purchase at Arby's of $$minimumPurchaseAmount$ or higher.</p> <p class="font10pt">$$minimumPurchaseAmount$ minimum purchase required to qualify. $$minimumPurchaseAmount$ minimum must be reached in a single transaction. Offer can be redeemed multiple times within award period.On average, you will receive notification of your $vc_currencyName$ award with 2-5 days of when the purchase occurred, due to bank and credit card processing.TM & &copy; 2012 Arby 's IP Holder Trust</p>},
             offers_virtual_currencies: [
               new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [
                 new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 4, end_date: '2999-12-31'),
                 new_tier(dollar_award_amount: 1.2, minimum_purchase_amount: 12, end_date: '2999-12-31'),
                 new_tier(dollar_award_amount: 11.5, minimum_purchase_amount: 130, end_date: '2999-12-31')
               ]
               )
             ]
)

create_offer(advertiser_id: burger_king.id, start_date: '1900-01-01', offers_virtual_currencies: [
  new_offers_virtual_currency(
    virtual_currency_id: virtual_currency.id,
    is_promotion: true,
    promotion_description: 'This is the greatest deal!!!',
    tiers: [
      new_tier(dollar_award_amount: 0.2, minimum_purchase_amount: 1, end_date: '2999-12-31'),
      new_tier(dollar_award_amount: 1.1, minimum_purchase_amount: 14, end_date: '2999-12-31'),
      new_tier(dollar_award_amount: 14.5, minimum_purchase_amount: 120, end_date: '2999-12-31')
    ]
  )
]
)

create_offer(advertiser_id: gap.id, start_date: '1900-01-01', is_new: true, offers_virtual_currencies: [
  new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [
    new_tier(dollar_award_amount: 0.8, minimum_purchase_amount: 1, end_date: '2999-12-31'),
    new_tier(dollar_award_amount: 9.5, minimum_purchase_amount: 19, end_date: '2999-12-31'),
    new_tier(dollar_award_amount: 12.5, minimum_purchase_amount: 141, end_date: '2999-12-31')
  ]
  )
]
)

p 'creating memolink offers'
    quiznos = create_advertiser(advertiser_name: 'Quiznos')
    create_offer(advertisers_rev_share: 0.08, advertiser_id: quiznos.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    outback_steakhouse = create_advertiser(advertiser_name: 'Outback Steakhouse')
    create_offer(advertisers_rev_share: 0.10,advertiser_id: outback_steakhouse.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    seven_eleven = create_advertiser(advertiser_name: '7 - Eleven')
    create_offer(advertisers_rev_share: 0.05,advertiser_id: seven_eleven.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    red_robin = create_advertiser(advertiser_name: 'Red Robin')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: red_robin.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    dunkin_donuts = create_advertiser(advertiser_name: "Dunkin' Donuts")
    create_offer(advertisers_rev_share: 0.02,advertiser_id: dunkin_donuts.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    burger_king = create_advertiser(advertiser_name: 'Burger King')
    create_offer(advertisers_rev_share: 0.05,advertiser_id: burger_king.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    regal_cinemas = create_advertiser(advertiser_name: 'Regal Cinemas')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: regal_cinemas.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    edwards_theatres = create_advertiser(advertiser_name: 'Edwards Theatres')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: edwards_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    united_artists_theatres = create_advertiser(advertiser_name: 'United Artists Theatres')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: united_artists_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    gap = create_advertiser(advertiser_name: 'Gap')
    create_offer(advertisers_rev_share: 0.1,advertiser_id: gap.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    old_navy = create_advertiser(advertiser_name: 'Old Navy')
    create_offer(advertisers_rev_share: 0.1,advertiser_id: old_navy.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    kmart = create_advertiser(advertiser_name: 'Kmart')
    create_offer(advertisers_rev_share: 0.05,advertiser_id: kmart.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    sears = create_advertiser(advertiser_name: 'Sears')
    create_offer(advertisers_rev_share: 0.05,advertiser_id: sears.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    dollar_general = create_advertiser(advertiser_name: 'Dollar General')
    create_offer(advertisers_rev_share: 0.03,advertiser_id: dollar_general.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    champs_sports = create_advertiser(advertiser_name: 'Champs Sports')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: champs_sports.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    eastbay_ccs = create_advertiser(advertiser_name: 'Eastbay/CCS')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: eastbay_ccs.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    footaction = create_advertiser(advertiser_name: 'Footaction')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: footaction.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    foot_locker = create_advertiser(advertiser_name: 'Foot Locker')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: foot_locker.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    puritans_pride = create_advertiser(advertiser_name: "Puritan's Pride")
    create_offer(advertisers_rev_share: 0.08,advertiser_id: puritans_pride.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

    vitamin_world = create_advertiser(advertiser_name: 'Vitamin World')
    create_offer(advertisers_rev_share: 0.08,advertiser_id: vitamin_world.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

p 'Creating Rewards'
wolfmart_reward = create_reward(name: 'Wolfmart', description: 'howl at the <a href="http://google.com">google</a>', logo_url: '/assets/test/amazon.png', terms: '<a href="#">wolfmart terms and conditions</a>')

create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 5)
create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 10)
create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 15)

create_reward(
  name: 'Tango Card', award_code: 'tango-card', description: 'it takes two', logo_url: '/assets/test/amazon.png', is_tango: true, terms: 'tango card terms and conditions',
  amounts:
    [
      new_reward_amount(dollar_award_amount: 5, is_active: true),
      new_reward_amount(dollar_award_amount: 10, is_active: true),
      new_reward_amount(dollar_award_amount: 15, is_active: false)
    ]
)

p 'Creating event types'
create_event_type(name: Plink::EventTypeRecord.email_capture_type)
create_event_type(name: Plink::EventTypeRecord.impression_type)
create_event_type(name: Plink::EventTypeRecord.login_type)
create_event_type(name: Plink::EventTypeRecord.card_add_type)
create_event_type(name: Plink::EventTypeRecord.card_change_type)

p 'Creating award type'
award_type = create_award_type(email_message: 'All the points!!!')
create_award_type(dollar_amount:1, award_code:'incentedJoin', email_message: 'incentedJoin')
create_award_type(dollar_amount:1, award_code:'pathIncentReferrals', email_message: 'pathIncentReferrals')
create_award_type(dollar_amount:1, award_code:'incentivizedAffiliateID', email_message: 'incentivizedAffiliateID')
create_award_type(dollar_amount:1, award_code:'friendReferral', email_message: 'friendReferral')
create_award_type(dollar_amount:1, award_code:'facebookLike', email_message: 'facebookLike')
create_award_type(dollar_amount:1, award_code:'questionAnswer', email_message: 'questionAnswer')
create_award_type(dollar_amount:1, award_code:'doubleConfirm', email_message: 'doubleConfirm')
create_award_type(dollar_amount:1, award_code:'incentedJoin', email_message: 'incentedJoin')
create_award_type(dollar_amount:1, award_code:'pathIncentReferrals', email_message: 'pathIncentReferrals')
create_award_type(dollar_amount:1, award_code:'incentivizedAffiliateID', email_message: 'incentivizedAffiliateID')
create_award_type(dollar_amount:1, award_code:'friendReferral', email_message: 'friendReferral')
create_award_type(dollar_amount:1, award_code:'facebookLike', email_message: 'facebookLike')
create_award_type(dollar_amount:1, award_code:'questionAnswer', email_message: 'questionAnswer')
create_award_type(dollar_amount:1, award_code:'doubleConfirm', email_message: 'doubleConfirm')

p 'Creating Free Award'
create_free_award(user_id: user.id, dollar_award_amount: 5430.43, currency_award_amount: 543043, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id)

p 'Creating Qualifying Award'
create_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Non-Qualifying Award'
create_non_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Redemption'
create_redemption(reward_id: wolfmart_reward.id, user_id: user.id, dollar_award_amount: 3.00)

p 'Creating News Articles'
create_news_article(title: 'Yay! Plink!', source: 'TechCrunch', source_link: 'http://techcrunch.com/plink', is_active: true, published_on: Date.yesterday)
