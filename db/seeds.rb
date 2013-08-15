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

p 'Create non-linked User'
user = create_user(password: 'password', email: 'non-linked@plink.com', avatar_thumbnail_url: 'http://img.gawkerassets.com/img/17m6znqc61o49jpg/original.jpg')
users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

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
vitamin_world = Plink::AdvertiserRecord.create(advertiser_name: 'Vitamin World', logo_url: '/assets/wallet-logos/vitaminworld.png')
puritans_pride = Plink::AdvertiserRecord.create(advertiser_name: "Puritan's Pride")
foot_locker = Plink::AdvertiserRecord.create(advertiser_name: 'Foot Locker', logo_url: '/assets/wallet-logos/footlocker.png')
footaction = Plink::AdvertiserRecord.create(advertiser_name: 'Footaction')
eastbay_ccs = Plink::AdvertiserRecord.create(advertiser_name: 'Eastbay/CCS')
champs_sports = Plink::AdvertiserRecord.create(advertiser_name: 'Champs Sports')
dollar_general = Plink::AdvertiserRecord.create(advertiser_name: 'Dollar General', logo_url: '/assets/wallet-logos/dollargeneral.png')
sears = Plink::AdvertiserRecord.create(advertiser_name: 'Sears', logo_url: '/assets/wallet-logos/sears.png')
kmart = Plink::AdvertiserRecord.create(advertiser_name: 'Kmart', logo_url: '/assets/wallet-logos/kmart.png')
united_artists_theatres = Plink::AdvertiserRecord.create(advertiser_name: 'United Artists Theatres', logo_url: '/assets/wallet-logos/unitedartists.png')
edwards_theatres = Plink::AdvertiserRecord.create(advertiser_name: 'Edwards Theatres')
regal_cinemas = Plink::AdvertiserRecord.create(advertiser_name: 'Regal Cinemas', logo_url: '/assets/wallet-logos/regal.png')
dunkin_donuts = Plink::AdvertiserRecord.create(advertiser_name: "Dunkin' Donuts", logo_url: '/assets/wallet-logos/dunkindonuts.png')
red_robin = Plink::AdvertiserRecord.create(advertiser_name: 'Red Robin', logo_url: '/assets/wallet-logos/redrobin.png')
seven_eleven = Plink::AdvertiserRecord.create(advertiser_name: '7 - Eleven', logo_url: '/assets/wallet-logos/7eleven.png')
quiznos = Plink::AdvertiserRecord.create(advertiser_name: 'Quiznos', logo_url: '/assets/wallet-logos/quiznos.png')
outback_steakhouse = Plink::AdvertiserRecord.create(advertiser_name: 'Outback Steakhouse', logo_url: '/assets/wallet-logos/outback.png')
old_navy = Plink::AdvertiserRecord.create(advertiser_name: 'Old Navy', logo_url: '/assets/wallet-logos/oldnavy.png')
arbys = Plink::AdvertiserRecord.create(advertiser_name: 'Arbys', logo_url: '/assets/wallet-logos/arbys.png')
burger_king = Plink::AdvertiserRecord.create(advertiser_name: 'Burger King', logo_url: '/assets/wallet-logos/bk-cropped.png')
gap = Plink::AdvertiserRecord.create(advertiser_name: 'Gap', logo_url: '/assets/wallet-logos/gap.png')


p 'Creating Plink Points Offers'
    create_offer(advertisers_rev_share: 0.08, advertiser_id: quiznos.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.10,advertiser_id: outback_steakhouse.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: seven_eleven.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: red_robin.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.02,advertiser_id: dunkin_donuts.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: burger_king.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: regal_cinemas.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: edwards_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: united_artists_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.1,advertiser_id: gap.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.1,advertiser_id: old_navy.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: kmart.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: sears.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.03,advertiser_id: dollar_general.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: champs_sports.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: eastbay_ccs.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: footaction.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: foot_locker.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: puritans_pride.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: vitamin_world.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

p 'Creating Memolink Offers'
    create_offer(advertisers_rev_share: 0.08, advertiser_id: quiznos.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.10,advertiser_id: outback_steakhouse.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: seven_eleven.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: red_robin.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.02,advertiser_id: dunkin_donuts.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: burger_king.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: regal_cinemas.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: edwards_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: united_artists_theatres.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.1,advertiser_id: gap.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.1,advertiser_id: old_navy.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: kmart.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.05,advertiser_id: sears.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.03,advertiser_id: dollar_general.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: champs_sports.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: eastbay_ccs.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: footaction.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: foot_locker.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: puritans_pride.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])
    create_offer(advertisers_rev_share: 0.08,advertiser_id: vitamin_world.id, start_date: '1900-01-01', offers_virtual_currencies: [ new_offers_virtual_currency(virtual_currency_id: memolink_virtual_currency.id, tiers: [ new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'), new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31') ]) ])

p 'Creating Plink Rewards'
amazon_reward = create_reward(name: 'Amazon.com Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Regal Cinemas Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Tango Card', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Walmart Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Airline Miles', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'iTunes&reg; Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Red Cross donation', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Facebook Credits', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: "Kohl's Gift Card", amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: "Macy's Gift Card", amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Overstock.com Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])
create_reward(name: 'Barnes and Noble Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true),])

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
create_redemption(reward_id: amazon_reward.id, user_id: user.id, dollar_award_amount: 3.00)

p 'Creating News Articles'
create_news_article(title: 'Yay! Plink!', source: 'TechCrunch', source_link: 'http://techcrunch.com/plink', is_active: true, published_on: 1.day.ago)
