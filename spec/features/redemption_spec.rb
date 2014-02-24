require 'spec_helper'

describe 'redeeming' do
  let!(:virtual_currency) { create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100) }
  let!(:user) { create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png') }
  let!(:fishy_transaction) { create_intuit_fishy_transaction(user_id: user.id, is_active: true) }

  before do
    create_wallet(user_id: user.id)
    create_reward(
      description: 'wally mart',
      is_tango: false,
      name: 'Walmart Gift Card',
      terms: '<a href="#">wally card terms</a>',
      amounts:
        [
          new_reward_amount(dollar_award_amount: 5, is_active: true),
          new_reward_amount(dollar_award_amount: 10, is_active: true),
          new_reward_amount(dollar_award_amount: 15, is_active: false),
          new_reward_amount(dollar_award_amount: 30, is_active: true)
        ]
    )

    create_reward(
      name: 'Tango Card', award_code: 'tango-card', description: '<a href="#">it takes two</a>', is_tango: true, terms: '<a href="#">Tango card terms</a>',
      amounts:
        [
          new_reward_amount(dollar_award_amount: 5, is_active: true),
          new_reward_amount(dollar_award_amount: 10, is_active: true),
          new_reward_amount(dollar_award_amount: 15, is_active: false)
        ]
    )

    link_card_for_user(user.id)
    award_points_to_user(user_id: user.id, dollar_award_amount: 10.00, currency_award_amount: 1000, virtual_currency_id: virtual_currency.id)

    sign_in('test@example.com', 'test123')
  end

  it 'allows users to redeem if they meet the correct criteria', :vcr, js: true, driver: :selenium  do
    click_on 'Rewards'

    page.should have_content "You have enough Plink Points to redeem for a Gift card."
    page.should have_content "Planning on having enough points for a larger gift card?"
    page.should have_content "Hold on to your points... We're updating our rewards system to provide discounts at the $50 & $100 levels!"
    within '.reward', text: 'Walmart Gift Card' do
      page.should have_css('.denomination.locked')
      page.should have_css('.flag-locked')
    end

    within '.reward', text: 'Walmart Gift Card' do
      page.find('a', text: '$5').click

      within '.modal' do
        page.find('a', text: 'TERMS & CONDITIONS').click
        page.should have_link "wally card terms"
      end
    end

    within '.reward', text: 'Walmart Gift Card' do
      page.find('a', text: '$5').click
      within '.modal' do
        page.should have_content '$5 Walmart Gift Card'
        click_on 'CONFIRM'
      end
    end

    page.should have_content 'We could not process your reward, please contact customer support.'

    fishy_transaction.update_attribute('is_active', false)

    within '.reward', text: 'Walmart Gift Card' do
      page.find('a', text: '$5').click
      within '.modal' do
        page.should have_content '$5 Walmart Gift Card'
        click_on 'CONFIRM'
      end
    end

    page.should have_content 'CONGRATS ON YOUR LOOT!'
    page.should have_content "You've succesfully redeemed for a $5 Walmart Gift Card."
    page.should have_content 'You have 500 Plink Points.'

    click_on 'Rewards'

    page.execute_script('$.fx.off = true;')

    within '.reward', text: 'Tango Card' do
      page.should have_link 'it takes two'
      page.find('a', text: '$5').click

      within '.modal' do
        click_on 'Terms & Conditions'
        page.should have_link 'Tango card terms'

        click_on 'Terms & Conditions'
        page.should_not have_content 'Tango card terms'

        click_on 'CANCEL'
      end
    end

    page.should have_content 'You have 500 Plink Points.'

    within '.reward', text: 'Tango Card' do
      page.should have_content 'it takes two'
      page.find('a', text: '$5').click
      within '.modal' do
        page.should have_content '$5 Tango Card'
        click_on 'CONFIRM'
      end
    end

    page.should have_content 'CONGRATS ON YOUR LOOT!'
    page.should have_content "You've succesfully redeemed for a $5 Tango Card."
    page.should have_link "it takes two"

    page.should have_content 'You have 0 Plink Points.'
  end
end
