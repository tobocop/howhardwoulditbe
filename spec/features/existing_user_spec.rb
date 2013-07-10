require 'spec_helper'

describe 'user signs in' do
  before(:each) do
    Tango::CardService.stub(:new).and_return(stub(:fake_card_service, purchase: stub(successful?:true)))

    create_hero_promotion(image_url: '/assets/hero-gallery/7eleven_1.jpg', display_order: 1, title: 'You want this.')
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    user = create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png')
    wallet = create_wallet(user_id: user.id)
    create_empty_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    user.primary_virtual_currency = virtual_currency
    user.save!

    link_card_for_user(user.id)

    award_points_to_user(user_id: user.id, dollar_award_amount: 10.43, currency_award_amount: 543, virtual_currency_id: virtual_currency.id)

    old_navy = create_advertiser(logo_url: '/assets/test/oldnavy.png', advertiser_name: 'Old Navy')
    burger_king = create_advertiser(logo_url: '/assets/test/burgerking.png', advertiser_name: 'Burger King')

    @old_navy_offer = create_offer(advertiser_id: old_navy.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: virtual_currency.id,
            tiers: [new_tier]
        )
    ])

    @burger_king_offer = create_offer(advertiser_id: burger_king.id,
                                      start_date: Date.yesterday,
                                      end_date: Date.tomorrow,
                                      is_active: true,
                                      show_on_wall: true,
                                      detail_text: 'You have to spend $minimumPurchaseAmount$ to get this',
                                      offers_virtual_currencies: [
                                          new_offers_virtual_currency(
                                              virtual_currency_id: virtual_currency.id,
                                              tiers: [
                                                  new_tier(minimum_purchase_amount: 15, dollar_award_amount: 1.50),
                                                  new_tier(minimum_purchase_amount: 2.50, dollar_award_amount: 0.50),
                                                  new_tier(minimum_purchase_amount: 25, dollar_award_amount: 3.00)
                                              ]
                                          )
                                      ])

    create_reward(name: 'Walmart Gift Card', amounts:
        [
            new_reward_amount(dollar_award_amount: 5, is_active: true),
            new_reward_amount(dollar_award_amount: 10, is_active: true),
            new_reward_amount(dollar_award_amount: 15, is_active: false)
        ]
    )

    create_reward(name: 'Tango Card', award_code: 'tango-card', is_tango: true, amounts:
      [
        new_reward_amount(dollar_award_amount: 5, is_active: true),
        new_reward_amount(dollar_award_amount: 10, is_active: true),
        new_reward_amount(dollar_award_amount: 15, is_active: false)
      ]
    )
  end

  it 'a registered user can have an active session', js: true do
    visit '/'

    click_on 'Sign In'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'test123'

    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Bob!')
    page.should have_content('You have 1043 Plink Points.')

    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_css('img[src="http://www.example.com/test.png"]')
    page.should have_content('You want this.')

    page.should have_css('#social-link-widget[gigid="showAddConnectionsUI"]')

    click_on 'Invite Friends'
    page.should have_css('[gigid="showShareUI"]')

    click_on 'Rewards'
    page.current_path.should == '/rewards'

    within '.reward', text: 'Walmart Gift Card' do
      click_on '$5.00'
    end

    page.should have_content('You have 543 Plink Points.')

    within '.reward', text: 'Tango Card' do
      click_on '$5.00'
    end

    page.should have_content('You have 43 Plink Points.')

    within '.reward', text: 'Walmart Gift Card' do
      click_on '$5.00'
    end

    page.should have_content('You do not have enough points to redeem.')

    click_on 'Wallet'

    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_content('You want this.')
    page.should_not have_css '.slot .brand'

    page.should have_content 'Select From These Offers'

    within "[data-offer-id='#{@old_navy_offer.id}']" do
      page.should have_css 'img[src="/assets/test/oldnavy.png"]'
    end

    within "[data-offer-id='#{@burger_king_offer.id}']" do
      page.should have_css 'img[src="/assets/test/burgerking.png"]'
      click_on 'Add to wallet'
    end

    within '.modal' do

      page.should have_content('Burger King Offers')

      within '.tiers' do
        within 'p:nth-of-type(1)' do
          page.should have_content '$2.50'
          page.should have_content '50 Plink Points'
        end

        within 'p:nth-of-type(2)' do
          page.should have_content '$15'
          page.should have_content '150 Plink Points'
        end

        within 'p:nth-of-type(3)' do
          page.should have_content '$25'
          page.should have_content '300 Plink Points'
        end
      end

      page.should have_content 'You have to spend 2.50 to get this'

      click_on 'Add To My Wallet'
    end

    page.should have_css '.slot .brand'

    click_on 'Remove'
    page.should_not have_css '.slot .brand'

    page.should have_content 'My Wallet'
    page.should have_content 'This slot is locked.'
    page.should have_content 'Complete an offer to unlock this slot.'

    page.execute_script('$.fx.off = true;')

    page.find('.slot.locked').click

    within '.modal' do
      page.should have_content 'Complete your first Plink offer and Expand your Plink Wallet'
      page.find('.close-btn').click
    end

    click_on 'Log Out'

    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')
  end
end