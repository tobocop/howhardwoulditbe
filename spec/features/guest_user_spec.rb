require 'spec_helper'

describe 'guest behavior' do

  before do
    currency = create_virtual_currency(name: 'Plink Points', subdomain: Plink::VirtualCurrency::DEFAULT_SUBDOMAIN)

    advertiser = create_advertiser(advertiser_name: 'Old Nervy', logo_url: '/assets/test/oldnavy.png')

    create_offer(
        advertiser_id: advertiser.id,
        detail_text: 'great deal',
        offers_virtual_currencies: [
            new_offers_virtual_currency(
                virtual_currency_id: currency.id,
                tiers: [
                    new_tier(
                        dollar_award_amount: 0.43
                    ),
                    new_tier(
                        dollar_award_amount: 1.43
                    )
                ]
            )
        ]
    )

    create_reward(name: 'Walmart Gift Card', amounts:
        [
            new_reward_amount(dollar_award_amount: 5, is_active: true),
            new_reward_amount(dollar_award_amount: 10, is_active: true)
        ]
    )
  end

  it 'can view offers and rewards' do
    visit '/'

    click_on 'view offers'

    page.should have_content 'Earn Plink Points at these locations.'
    page.should have_css('img[src="/assets/test/oldnavy.png"]')
    page.should have_content '143 Plink Points'

    visit '/rewards'

    page.should have_content 'Redeem Plink Points for these rewards'
    page.should have_content 'Walmart Gift Card'
    page.should have_content '$5'
    page.should have_content '$10'
  end
end
