require 'plink/test_helpers/object_creation_methods'

include Plink::ObjectCreationMethods

Plink::User.destroy_all
Plink::OauthToken.destroy_all
Plink::UsersInstitutionAccount.destroy_all
Plink::AwardType.destroy_all
Plink::FreeAwardRecord.destroy_all
Plink::VirtualCurrency.destroy_all
HeroPromotion.destroy_all
Plink::AdvertiserRecord.destroy_all
Plink::OfferRecord.destroy_all
Plink::OffersVirtualCurrencyRecord.destroy_all
Plink::TierRecord.destroy_all
Plink::RewardRecord.destroy_all
Plink::RewardAmountRecord.destroy_all

p 'Creating VirtualCurrency'
virtual_currency = Plink::VirtualCurrency.create(name: "Plink points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")

p 'Creating Dev user'
user = create_user(password:'password', email: 'pivotal@plink.com')
wallet = create_wallet(user_id: user.id)
3.times { |i| create_open_wallet_item(wallet_id: wallet.id, wallet_slot_id: i+1) }
create_locked_wallet_item(wallet_id: wallet.id)

p 'Linking Dev User'
create_oauth_token(user_id: user.id)
create_users_institution_account(user_id: user.id)

p 'Creating award type'
award_type = create_award_type

p 'Creating Free Award'
create_free_award(user_id: user.id, dollar_award_amount:5430.43, currency_award_amount: 543043, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id)


p 'Creating HeroPromotions'
HeroPromotion.create(image_url: '/assets/hero-gallery/bk_2.jpg', title: 'Get Double Points at Burger King', display_order: 1)
HeroPromotion.create(image_url: '/assets/hero-gallery/TacoBell_2.jpg', title: 'New Partner - Taco Bell', display_order: 2)
HeroPromotion.create(image_url: '/assets/hero-gallery/7eleven_2.jpg', title: '7-Eleven = AMAZING HOTDOGS', display_order: 3)

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

create_offer(advertiser_id: gap.id, start_date: '1900-01-01', offers_virtual_currencies: [
    new_offers_virtual_currency(virtual_currency_id: virtual_currency.id, tiers: [
        new_tier(dollar_award_amount: 0.8, minimum_purchase_amount: 1, end_date: '2999-12-31'),
        new_tier(dollar_award_amount: 9.5, minimum_purchase_amount: 19, end_date: '2999-12-31'),
        new_tier(dollar_award_amount: 12.5, minimum_purchase_amount: 141, end_date: '2999-12-31')
    ]
    )
]
)

p 'Creating Rewards'
wolfmart_reward = create_reward(name: 'Wolfmart')

create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 5)
create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 10)
create_reward_amount(reward_id: wolfmart_reward.id, is_active: true, dollar_award_amount: 15)


create_reward(name: 'Tango Card', award_code: 'tango-card', is_tango: true, amounts:
  [
    new_reward_amount(dollar_award_amount: 5, is_active: true),
    new_reward_amount(dollar_award_amount: 10, is_active: true),
    new_reward_amount(dollar_award_amount: 15, is_active: false)
  ]
)