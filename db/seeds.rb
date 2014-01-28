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
Plink::TangoTrackingRecord.destroy_all
Plink::RedemptionRecord.destroy_all
Plink::InstitutionRecord.destroy_all
Plink::UsersInstitutionRecord.destroy_all
Plink::WalletItemRecord.destroy_all
Plink::WalletRecord.destroy_all
Plink::UsersAwardPeriodRecord.destroy_all
Plink::ContestRecord.destroy_all

p 'Creating VirtualCurrency'
memolink_virtual_currency = Plink::VirtualCurrency.create(name: 'memolink points', subdomain: 'memolink', exchange_rate: 1600, site_name: 'Memolink', singular_name: 'memolink point')
plink_virtual_currency = Plink::VirtualCurrency.create(name: 'Plink points', subdomain: 'www', exchange_rate: 100, site_name: 'Plink', singular_name: 'Plink Point')
swagbucks_virtual_currency = Plink::VirtualCurrency.create(name: 'Swag Bucks', subdomain: 'swagbucks', exchange_rate: 100, site_name: 'Swagbucks', singular_name: 'Swag Buck', has_all_offers: true)
bestbuy_virtual_currency = Plink::VirtualCurrency.create(name: 'Reward Zone<sup>&reg;</sup> points', subdomain: 'bestbuy', exchange_rate: 50, site_name: 'Reward Zone Out & About', singular_name: 'Reward Zone<sup>&reg;</sup> point', has_all_offers: true)
goodsearch_virtual_currency = Plink::VirtualCurrency.create(name: 'towards your cause', subdomain: 'goodsearch', exchange_rate: 1, site_name: 'Goodswipe', singular_name: 'towards your cause', has_all_offers: true, show_tiers_as_percent: true)

p 'Creating institution'
institution = create_institution(name: 'Bank of AMERRRICA!')
create_institution(name: 'CC Bank', intuit_institution_id: 100000)

p 'Create non-linked User'
user = create_user(password: 'password', email: 'clean_account@plink.com', avatar_thumbnail_url: 'http://img.gawkerassets.com/img/17m6znqc61o49jpg/original.jpg')
users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: plink_virtual_currency.id)
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Creating Dev user'
user = create_user(password: 'password', email: 'pivotal@plink.com', avatar_thumbnail_url: 'http://img.gawkerassets.com/img/17m6znqc61o49jpg/original.jpg')
users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: plink_virtual_currency.id)
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Creating QA user'
qa_user = create_user(firstName: 'Matt', password: 'test123', email: 'matt@plink.com', avatar_thumbnail_url: 'http://baconmockup.com/96/96')
users_virtual_currency = create_users_virtual_currency(user_id: qa_user.id, virtual_currency_id: plink_virtual_currency.id)
qa_wallet = create_wallet(user_id: qa_user.id)
3.times { |i| create_open_wallet_item(wallet_id: qa_wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: qa_wallet.id)

p 'Linking Dev User'
users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
create_oauth_token(user_id: user.id)
create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id, name: 'Tiny checking account', account_number_last_four: 2341)

p 'Creating user that needs reverification'
user_reverify = create_user(password: 'password', email: 'reverify@plink.com')
users_virtual_currency = create_users_virtual_currency(user_id: user_reverify.id, virtual_currency_id: plink_virtual_currency.id)
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
p 'Creating Admin Sales user'
PlinkAdmin::Admin.new { |admin| admin.email ='sales@plink.com'; admin.password = 'password'; admin.sales = true; admin.save; }

p 'Creating HeroPromotions'
Plink::HeroPromotionRecord.create(name: 'Yo-hiness', image_url_one: '/assets/hero-gallery/bk_2.jpg', title: 'Get Double Points at Burger King', display_order: 1)
Plink::HeroPromotionRecord.create(name: 'Stefan', image_url_one: '/assets/hero-gallery/TacoBell_2.jpg', title: 'New Partner - Taco Bell', display_order: 2)
Plink::HeroPromotionRecord.create(name: 'Georg', image_url_one: '/assets/hero-gallery/7eleven_2.jpg', title: '7-Eleven = AMAZING HOTDOGS', display_order: 3)

p 'Creating Advertisers'
vitamin_world = create_advertiser(advertiser_name: 'Vitamin World', logo_url: "offerImages/vitaminworld.png", map_search_term: 'Vitamin World')
puritans_pride = create_advertiser(advertiser_name: "Puritan's Pride", logo_url: "offerImages/puritansPride2.png", map_search_term: "Puritan's Pride")
foot_locker = create_advertiser(advertiser_name: 'Foot Locker', logo_url: "offerImages/footlocker_v4.png", map_search_term: 'Foot Locker')
footaction = create_advertiser(advertiser_name: 'Footaction', logo_url: "offerImages/footaction_v2.png", map_search_term: 'Footaction')
eastbay_ccs = create_advertiser(advertiser_name: 'Eastbay/CCS', logo_url: "offerImages/eastbay-ccs_v3.png", map_search_term: 'Eastbay/CCS')
champs_sports = create_advertiser(advertiser_name: 'Champs Sports', logo_url: "offerImages/champs.png", map_search_term: 'Champs Sports')
dollar_general = create_advertiser(advertiser_name: 'Dollar General', logo_url: "offerImages/dollarGeneral_v2.png", map_search_term: 'Dollar General')
sears = create_advertiser(advertiser_name: 'Sears', logo_url: "offerImages/sears.png", map_search_term: 'Sears')
kmart = create_advertiser(advertiser_name: 'Kmart', logo_url: "offerImages/Kmart.png", map_search_term: 'Kmart')
united_artists_theatres = create_advertiser(advertiser_name: 'United Artists Theatres', logo_url: "offerImages/unitedArtists.png", map_search_term: 'United Artists Theatres')
edwards_theatres = create_advertiser(advertiser_name: 'Edwards Theatres', logo_url: "offerImages/edwardsTheatres.png", map_search_term: 'Edwards Theatres')
regal_cinemas = create_advertiser(advertiser_name: 'Regal Cinemas', logo_url: "offerImages/regalCinemasFull.png", map_search_term: 'Regal Cinemas')
dunkin_donuts = create_advertiser(advertiser_name: "Dunkin' Donuts", logo_url: "offerImages/dunkinDonuts.png", map_search_term: "Dunkin' Donuts")
red_robin = create_advertiser(advertiser_name: 'Red Robin', logo_url: "offerImages/redRobin.png", map_search_term: 'Red Robin')
seven_eleven = create_advertiser(advertiser_name: '7 - Eleven', logo_url: "offerImages/sevenEleven.png", map_search_term: '7 - Eleven')
quiznos = create_advertiser(advertiser_name: 'Quiznos', logo_url: "offerImages/quiznos.png", map_search_term: 'Quiznos')
outback_steakhouse = create_advertiser(advertiser_name: 'Outback Steakhouse', logo_url: "offerImages/outback.png", map_search_term: 'Outback Steakhouse')
old_navy = create_advertiser(advertiser_name: 'Old Navy', logo_url: "offerImages/old_navy.png", map_search_term: 'Old Navy')
burger_king = create_advertiser(advertiser_name: 'Burger King', logo_url: "offerImages/burgerKing.png", map_search_term: 'Burger King')
gap = create_advertiser(advertiser_name: 'Gap', logo_url: "offerImages/burgerKing.png", map_search_term: 'Gap')

p 'Creating Offers'
offers = {
    quiznos: create_offer(advertisers_rev_share: 0.08, advertiser_id: quiznos.id, start_date: '1900-01-01'),
    outback_steakhouse: create_offer(advertisers_rev_share: 0.10,advertiser_id: outback_steakhouse.id, start_date: '1900-01-01'),
    seven_eleven: create_offer(advertisers_rev_share: 0.05,advertiser_id: seven_eleven.id, start_date: '1900-01-01'),
    red_robin: create_offer(advertisers_rev_share: 0.08,advertiser_id: red_robin.id, start_date: '1900-01-01'),
    dunkin_donuts: create_offer(advertisers_rev_share: 0.02,advertiser_id: dunkin_donuts.id, start_date: '1900-01-01'),
    burger_king: create_offer(advertisers_rev_share: 0.05,advertiser_id: burger_king.id, start_date: '1900-01-01'),
    regal_cinemas: create_offer(advertisers_rev_share: 0.08,advertiser_id: regal_cinemas.id, start_date: '1900-01-01'),
    edwards_theatres: create_offer(advertisers_rev_share: 0.08,advertiser_id: edwards_theatres.id, start_date: '1900-01-01'),
    united_artists_theatres: create_offer(advertisers_rev_share: 0.08,advertiser_id: united_artists_theatres.id, start_date: '1900-01-01'),
    gap: create_offer(advertisers_rev_share: 0.1,advertiser_id: gap.id, start_date: '1900-01-01'),
    old_navy: create_offer(advertisers_rev_share: 0.1,advertiser_id: old_navy.id, start_date: '1900-01-01'),
    kmart: create_offer(advertisers_rev_share: 0.05,advertiser_id: kmart.id, start_date: '1900-01-01'),
    sears: create_offer(advertisers_rev_share: 0.05,advertiser_id: sears.id, start_date: '1900-01-01'),
    dollar_general: create_offer(advertisers_rev_share: 0.03,advertiser_id: dollar_general.id, start_date: '1900-01-01'),
    champs_sports: create_offer(advertisers_rev_share: 0.08,advertiser_id: champs_sports.id, start_date: '1900-01-01'),
    eastbay_ccs: create_offer(advertisers_rev_share: 0.08,advertiser_id: eastbay_ccs.id, start_date: '1900-01-01'),
    footaction: create_offer(advertisers_rev_share: 0.08,advertiser_id: footaction.id, start_date: '1900-01-01'),
    foot_locker: create_offer(advertisers_rev_share: 0.08,advertiser_id: foot_locker.id, start_date: '1900-01-01'),
    puritans_pride: create_offer(advertisers_rev_share: 0.08,advertiser_id: puritans_pride.id, start_date: '1900-01-01'),
    vitamin_world: create_offer(advertisers_rev_share: 0.08,advertiser_id: vitamin_world.id, start_date: '1900-01-01')
}

p 'Creating Plink Points And Memolink Points Offers Virtual Currencies'
[plink_virtual_currency, memolink_virtual_currency].each do |virtual_currency|
  offers.each do |offer_name, offer_record|
    create_offers_virtual_currency(
      offer_id: offer_record.id,
      virtual_currency_id: virtual_currency.id,
      tiers: [
        new_tier(dollar_award_amount: 0.5, minimum_purchase_amount: 5, end_date: '2999-12-31'),
        new_tier(dollar_award_amount: 1.5, minimum_purchase_amount: 5, end_date: '2999-12-31')
      ]
    )
  end
end

p 'Creating swagbucks, bestbuy, and goodsearch Offers Virtual Currencies'
[swagbucks_virtual_currency, bestbuy_virtual_currency, goodsearch_virtual_currency].each do |virtual_currency|
  offers.each do |offer_name, offer_record|
    create_offers_virtual_currency(
      offer_id: offer_record.id,
      virtual_currency_id: virtual_currency.id,
      tiers: [
        new_tier(dollar_award_amount: 0, minimum_purchase_amount: 0.01, percent_award_amount: 3.0, end_date: '2999-12-31')
      ]
    )
  end
end

p 'Creating Plink Rewards'
amazon_reward = create_reward(name: 'Amazon.com Gift Card', terms: 'legal terms', award_code: 'amazon-gift-card', is_tango: true, amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Online retailer of books, movies, music and games along with electronics, toys, apparel, sports, tools, groceries and general home and garden items.")
create_reward(name: 'Walmart Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/walmart.png', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "The Walmart eGift Card is great for anyone, any time of year. Walmart eGift Cards can be used online at Walmart.com or Samsclub.com.")
create_reward(name: 'iTunes&reg; Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/itunes.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: " iTunes gift cards are perfect for anyone who enjoys one-stop entertainment. Each code is redeemable for music, movies, TV shows, games, and more.")
create_reward(name: 'Tango Card', terms: 'legal terms', logo_url: '/assets/gift-cards/tango.png', award_code: 'tango-card', is_tango: true, amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Tango Card is the most versatile gift card yet. Select from top-name brands like iTunes&reg;, Target, Home Depot, Starbucks and more. You can also also redeem any unused balance for cash. Click here for more information.")
create_reward(name: 'Facebook Credits', terms: 'legal terms', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true), new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Get Virtual Goods in Your Favorite Games")
create_reward(name: 'Subway Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/subway.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 20, is_active: true)], description: "Redeem your SUBWAY&reg; Card today, and you'll always have a delicious meal right at your fingertips.")
create_reward(name: 'Red Cross donation', terms: 'legal terms', logo_url: '/assets/gift-cards/redcross.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "A gift of any size supports the lifesaving mission of the American Red Cross whether it's responding to a disaster, collecting lifesaving blood, or assisting our military members and their families.")
create_reward(name: 'Regal Cinemas Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/regal.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "The largest movie theater circuit featuring major motion pictures, digital movie presentation, and RealD Digital 3D.")
create_reward(name: 'Overstock.com Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/overstock.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Overstock. Let the savings begin!")
create_reward(name: 'Barnes and Noble Gift Card', terms: 'legal terms', logo_url: '/assets/gift-cards/barnesandnoble.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Lower Prices on Millions of Books, Movies and TV Show DVDs and Blu-ray, Music, Toys, and Games.")
create_reward(name: 'Airline Miles', terms: 'legal terms', logo_url: '/assets/gift-cards/airlinemiles.png', amounts: [ new_reward_amount(dollar_award_amount: 10, is_active: true), new_reward_amount(dollar_award_amount: 15, is_active: true), new_reward_amount(dollar_award_amount: 25, is_active: true), new_reward_amount(dollar_award_amount: 50, is_active: true), new_reward_amount(dollar_award_amount: 100, is_active: true)], description: "Redeem Plink Points for airline miles or points to the following programs: Alaskan Airlines Milage, American Airlines Advantage, Frontier Early Returns, Hawaiian Miles, and more.")

p 'Creating event types'
create_event_type(name: Plink::EventTypeRecord.registration_start_type)
create_event_type(name: Plink::EventTypeRecord.email_capture_type)
create_event_type(name: Plink::EventTypeRecord.impression_type)
create_event_type(name: Plink::EventTypeRecord.login_type)
create_event_type(name: Plink::EventTypeRecord.card_add_type)
create_event_type(name: Plink::EventTypeRecord.card_change_type)
create_event_type(name: Plink::EventTypeRecord.facebook_login_type)
create_event_type(name: Plink::EventTypeRecord.offer_activate_type)
create_event_type(name: Plink::EventTypeRecord.offer_deactivate_type)

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

p 'Creating Free Awards'
create_free_award(user_id: user.id, dollar_award_amount: 5430.43, currency_award_amount: 543043, award_type_id: award_type.id, virtual_currency_id: plink_virtual_currency.id)
create_free_award(user_id: qa_user.id, dollar_award_amount: 125, currency_award_amount: 12500, award_type_id: award_type.id, virtual_currency_id: plink_virtual_currency.id)

p 'Creating Qualifying Awards'
create_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: plink_virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)
create_qualifying_award(user_id: qa_user.id, advertiser_id: old_navy.id, virtual_currency_id: plink_virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Non-Qualifying Award'
create_non_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: plink_virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Redemption'
create_redemption(reward_id: amazon_reward.id, user_id: user.id, dollar_award_amount: 5.00)
create_redemption(reward_id: amazon_reward.id, user_id: qa_user.id, dollar_award_amount: 5.00)

p 'Creating News Articles'
create_news_article(title: 'Yay! Plink!', source: 'TechCrunch', source_link: 'http://techcrunch.com/plink', is_active: true, published_on: 1.day.ago)

p 'Creating Contest'
create_contest(start_time: 1.day.ago.to_date, end_time: 100.days.from_now)
