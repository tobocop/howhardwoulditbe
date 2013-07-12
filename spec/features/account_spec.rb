require 'spec_helper'

describe 'Managing account' do
  before(:each) do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    user = create_user(email: 'user@example.com', password: 'pass1word')
    users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
    create_oauth_token(user_id: user.id)

    institution = create_institution(name: 'Bank of representin')
    users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
    create_users_institution_account(user_id: user.id, name: 'representing checks', users_institution_id: users_institution.id, account_number_last_four: 4321)

    advertiser = create_advertiser(advertiser_name: 'Pop Caps inc')

    award_points_to_user(
      user_id: user.id,
      dollar_award_amount: 4.35,
      currency_award_amount: 435,
      award_message: 'this is a free award',
      virtual_currency_id: virtual_currency.id,
      type: 'free'
    )

    award_points_to_user(
      user_id: user.id,
      dollar_award_amount: 4.25,
      currency_award_amount: 425,
      virtual_currency_id: virtual_currency.id,
      users_virtual_currency_id: users_virtual_currency.id,
      advertiser_id: advertiser.id,
      type: 'qualifying'
    )

    award_points_to_user(
      user_id: user.id,
      dollar_award_amount: 0.20,
      currency_award_amount: 20,
      virtual_currency_id: virtual_currency.id,
      users_virtual_currency_id: users_virtual_currency.id,
      advertiser_id: advertiser.id,
      type: 'nonqualifying'
    )

    reward = create_reward(name: 'Walmart Gift Card')

    create_redemption(reward_id: reward.id, user_id: user.id, dollar_award_amount:3.00)
  end

  it 'allows a user to manage their account', js: true, driver: :selenium do
    sign_in('user@example.com', 'pass1word')

    click_link 'My Account'

    page.should have_link 'Link Card'
    page.should have_content 'YOUR BANK'
    page.should have_content 'Bank of representin'
    page.should have_content 'YOUR CARD'
    page.should have_content 'representing checks 4321'

    page.should have_content 'You have 580 Plink Points.'
    page.should have_content 'Lifetime balance: 880 Plink Points'

    page.should_not have_link 'Redeem'

    page.should have_content 'RECENT ACTIVITY'

    within '.activity' do
      within '.event:nth-of-type(2)' do
        page.should have_content Date.today.to_s(:month_day)
        page.should have_content 'Walmart Gift Card'
        page.should have_content '-300 Plink Points'
        page.should have_image 'history/icon_redeem.png'
      end

      within '.event:nth-of-type(3)' do
        page.should have_content Date.today.to_s(:month_day)
        page.should have_content 'for participating in the Plink program'
        page.should have_content '20 Plink Points'
        page.should have_image 'history/icon_bonus.png'
      end

      within '.event:nth-of-type(4)' do
        page.should have_content Date.today.to_s(:month_day)
        page.should have_content 'Pop Caps inc'
        page.should have_content '425 Plink Points'
        page.should have_image 'history/icon_purchase.png'
      end

      within '.event:nth-of-type(5)' do
        page.should have_content Date.today.to_s(:month_day)
        page.should have_content 'this is a free award'
        page.should have_content '435 Plink Points'
        page.should have_image 'history/icon_bonus.png'
      end
    end

    page.should have_css '#social-link-widget'
  end
end
