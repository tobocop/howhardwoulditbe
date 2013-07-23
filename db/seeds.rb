require 'plink/test_helpers/object_creation_methods'

include Plink::ObjectCreationMethods

Plink::UserRecord.destroy_all
PlinkAdmin::Admin.destroy_all
Plink::OauthToken.destroy_all
Plink::UsersInstitutionAccountRecord.destroy_all
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
Plink::UsersAwardPeriodRecord.destroy_all

p 'Creating VirtualCurrency'
virtual_currency = Plink::VirtualCurrency.create(name: "Plink points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")

p 'Creating Dev user'
user = create_user(password: 'password', email: 'pivotal@plink.com')
users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Creating Admin user'
PlinkAdmin::Admin.new do |admin|
  admin.email ='pivotal@plink.com'
  admin.password = 'password'
  admin.save
end

p 'Creating institution'
institution = create_institution(name: 'Bank of AMERRRICA!')
users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)

p 'Linking Dev User'
create_oauth_token(user_id: user.id)
create_users_institution_account(user_id: user.id, users_institution_id: users_institution.id, name: 'Tiny checking account', account_number_last_four: 2341)

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
  new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [
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

p 'Creating Rewards'
wolfmart_reward = create_reward(name: 'Wolfmart', description: 'howl', logo_url: '/assets/test/amazon.png', terms: '<a href="#">wolfmart terms and conditions</a>')

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

p 'Creating award type'
award_type = create_award_type(email_message: 'All the points!!!')

p 'Creating Free Award'
create_free_award(user_id: user.id, dollar_award_amount: 5430.43, currency_award_amount: 543043, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id)

p 'Creating Qualifying Award'
create_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Non-Qualifying Award'
create_non_qualifying_award(user_id: user.id, advertiser_id: old_navy.id, virtual_currency_id: virtual_currency.id, users_virtual_currency_id: users_virtual_currency.id)

p 'Creating Redemption'
create_redemption(reward_id: wolfmart_reward.id, user_id: user.id, dollar_award_amount: 3.00)

