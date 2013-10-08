require 'spec_helper'

describe 'user signs in' do
  before(:each) do
    Tango::CardService.stub(:new).and_return(stub(:fake_card_service, purchase: stub(successful?: true)))

    create_hero_promotion(image_url: '/assets/hero-gallery/7eleven_1.jpg', display_order: 1, title: 'You want this.')
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    user = create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png')
    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    user.primary_virtual_currency = virtual_currency
    user.save!

    link_card_for_user(user.id)

    award_points_to_user(user_id: user.id, dollar_award_amount: 100.00, currency_award_amount: 10000, virtual_currency_id: virtual_currency.id)

    old_navy = create_advertiser(logo_url: '/assets/test/oldnavy.png', advertiser_name: 'Old Navy Test')
    burger_king = create_advertiser(logo_url: '/assets/test/burgerking.png', advertiser_name: 'Burger King')

    @old_navy_offer = create_offer(advertiser_id: old_navy.id,
                                   start_date: 1.day.ago,
                                   end_date: 1.day.from_now,
                                   is_active: true,
                                   show_on_wall: true,
                                   offers_virtual_currencies: [
                                     new_offers_virtual_currency(
                                       is_promotion: true,
                                       promotion_description: 'This is a double offer',
                                       virtual_currency_id: virtual_currency.id,
                                       tiers: [new_tier]
                                     )
                                   ])

    @burger_king_offer = create_offer(advertiser_id: burger_king.id,
                                      start_date: 1.day.ago,
                                      end_date: Time.zone.local(2020, 2, 1),
                                      is_active: true,
                                      is_new: true,
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

    create_reward(
      name: 'Walmart Gift Card', description: 'wally mart', terms: '<a href="#">wally card terms</a>',
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
  end

  it 'a registered user can have an active session', js: true, driver: :selenium do
    sign_in('test@example.com', 'test123')

    page.should have_content('Welcome, Bob!')
    page.should have_content('You have 10000 Plink Points.')

    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_content('You want this.')

    within '.welcome-text' do
      page.should have_css 'span.redeemable'
    end

    click_on 'Rewards'

    page.current_path.should == '/rewards'

    page.should have_content "You have enough Plink Points to redeem for a Gift card."

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

    page.should have_content 'CONGRATS ON YOUR LOOT!'
    page.should have_content "You've succesfully redeemed for a $5 Walmart Gift Card."
    page.should have_content('You have 9500 Plink Points.')

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

    page.should have_content('You have 9500 Plink Points.')

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

    page.should have_content('You have 9000 Plink Points.')

    click_on 'Rewards'

    within '.reward', text: 'Walmart Gift Card' do
      page.should have_content 'wally mart'
    end

    click_on 'Rewards'

    page.execute_script('$.fx.off = true;')

    page.should have_content "Planning on having enough points for a larger gift card?"
    page.should have_content "Hold on to your points... We're updating our rewards system to provide discounts at the $50 & $100 levels!"
    within '.reward', text: 'Walmart Gift Card' do
      page.should have_css('.denomination.locked')
      page.should have_css('.flag-locked')
    end

    click_on 'Wallet'

    page.execute_script('$.fx.off = true;')

    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_content('You want this.')
    page.should_not have_css '.slot .brand'

    within '.right-column', text: 'SELECT FROM THESE OFFERS' do
      page.should have_content 'SELECT FROM THESE OFFERS'

      page.should have_css("[data-offer-id]", count: 2)

      within "[data-offer-id='#{@old_navy_offer.id}']" do
        page.should have_css '.ribbon.ribbon-promo-offer', text: 'Get double points when you make a qualifying purchase at this partner.'
        page.should have_css 'img[src="/assets/test/oldnavy.png"]'
        click_on 'Add to wallet'
      end

      within '.modal' do
        page.should have_content 'This is a double offer'
        page.should have_css '.modal-ribbon.ribbon-promo-offer', text: 'Get double points when you make a qualifying purchase at this partner.'
      end

      within "[data-offer-id='#{@burger_king_offer.id}']" do
        page.should have_css 'img[src="/assets/test/burgerking.png"]'
        page.should have_css '.ribbon.ribbon-new-offer', text: 'New Partner!'
        click_on 'Add to wallet'
      end
    end

    within '.modal' do

      page.should have_css '.modal-ribbon.ribbon-new-offer', text: 'New Partner!'

      within '.bg-element' do
        within '.offer-points:nth-of-type(1)' do
          page.should have_content '$2.50'
          page.should have_content '50 Plink Points'
        end

        within '.offer-points:nth-of-type(2)' do
          page.should have_content '$15'
          page.should have_content '150 Plink Points'
        end

        within '.offer-points:nth-of-type(3)' do
          page.should have_content '$25'
          page.should have_content '300 Plink Points'
        end

        #TODO: put this back in once Marc has approved launch
        #page.should have_content 'This offer is only available through 2/1/20'
      end

      page.should have_content 'You have to spend 2.50 to get this'

      click_on 'Add To My Wallet'
    end

    within '.right-column', text: 'SELECT FROM THESE OFFERS' do
      page.should have_css("[data-offer-id]", count: 1)

      within "[data-offer-id='#{@old_navy_offer.id}']" do
        page.should have_css 'img[src="/assets/test/oldnavy.png"]'
      end
    end

    within '#wallet_items_bucket' do
      within '.slot:nth-of-type(1)' do
        page.should have_css 'img[src="/assets/test/burgerking.png"]'
        page.should have_css '.ribbon.ribbon-new-offer', text: 'New Partner!'
      end
    end

    page.should have_css '.slot .brand'

    within "[data-offer-id='#{@old_navy_offer.id}']" do
      page.should have_css 'img[src="/assets/test/oldnavy.png"]'
      click_on 'Add to wallet'
    end

    within '.modal' do
      click_on 'Add To My Wallet'

      page.should have_content("You don't have any open slots in your Plink Wallet. To add this offer, remove one of the offers currently in your Plink Wallet.")
    end

    click_on 'Remove'

    within '.modal' do
      click_on 'Remove'
    end

    within '.right-column', text: 'SELECT FROM THESE OFFERS' do
      page.should have_content 'SELECT FROM THESE OFFERS'

      page.should have_css("[data-offer-id]", count: 2)

      within "[data-offer-id='#{@old_navy_offer.id}']" do
        page.should have_css 'img[src="/assets/test/oldnavy.png"]'
      end

      within "[data-offer-id='#{@burger_king_offer.id}']" do
        page.should have_css 'img[src="/assets/test/burgerking.png"]'
        click_on 'Add to wallet'
      end
    end

    page.should_not have_css '.slot .brand'

    page.should have_content 'My Wallet'
    page.should have_content 'This slot is locked.'
    page.should have_content 'Complete an offer or refer a friend to unlock this slot.'

    page.execute_script('$.fx.off = true;')

    page.find('.slot.locked').click

    within '.modal' do
      page.should have_content 'One wallet slot will unlock after your first qualified purchase* and one slot will open with your first friend referral**.'
      page.find('.close-btn').click
    end

    click_on 'Rewards'
    current_path.should == '/rewards'
    page.should have_css('img[src="/assets/header_logo.png"]')
    find(".header-logo").click
    current_path.should == '/wallet'

    visit '/'
    current_path.should == '/wallet'

    click_on('Contact Us', match: :first)
    submit_contact_us_form('Matt', 'Tester', 'non@member.com',
      'Im a lumberjack and im ok I sleep all night and work all day')
    page.current_path.should == '/wallet'
    page.should have_text('Thank you for contacting Plink.')

    visit '/'
    click_on 'Log Out'

    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')

    page.should have_css('img[src="/assets/header_logo.png"]')
    find(".header-logo").click
    current_path.should == '/'
  end
end
