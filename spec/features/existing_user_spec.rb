require 'spec_helper'

describe 'user signs in' do
  let!(:user) { create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png') }

  before do
    create_hero_promotion(image_url_one: '/assets/hero-gallery/TacoBell_1.jpg', display_order: 1, title: 'You want this.', show_linked_users: false )
    create_hero_promotion(image_url_one: '/assets/hero-gallery/bk2.jpg', display_order: 1, title: 'You really want this.', show_linked_users: true )
    create_hero_promotion(image_url_one: '/assets/hero-gallery/7eleven_1.jpg',image_url_two: '/assets/hero-gallery/bk1.jpg', display_order: 2, title: 'You want this.', show_linked_users: true )
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    user.primary_virtual_currency = virtual_currency
    user.save!

    link_card_for_user(user.id)

    award_points_to_user(user_id: user.id, dollar_award_amount: 100.00, currency_award_amount: 10000, virtual_currency_id: virtual_currency.id)
    create_reward(amounts: [new_reward_amount(dollar_award_amount: 5, is_active: true)])

    old_navy = create_advertiser(logo_url: '/assets/test/oldnavy.png', advertiser_name: 'Old Navy Test')
    burger_king = create_advertiser(logo_url: '/assets/test/burgerking.png', advertiser_name: 'Burger King')

    @old_navy_offer = create_offer(
      advertiser_id: old_navy.id,
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
      ]
    )

    @burger_king_offer = create_offer(
      advertiser_id: burger_king.id,
      start_date: 1.day.ago,
      end_date: Time.zone.local(2020, 2, 1),
      is_active: true,
      is_new: true,
      show_on_wall: true,
      detail_text: 'You have to spend $minimumPurchaseAmount$ to get this',
      show_end_date: true,
      offers_virtual_currencies: [
        new_offers_virtual_currency(
          virtual_currency_id: virtual_currency.id,
          tiers: [
            new_tier(minimum_purchase_amount: 15, dollar_award_amount: 1.50),
            new_tier(minimum_purchase_amount: 2.50, dollar_award_amount: 0.50),
            new_tier(minimum_purchase_amount: 25, dollar_award_amount: 3.00)
          ]
        )
      ]
    )
  end

  it 'a registered user can have an active session', :vcr, js: true, driver: :selenium do
    sign_in('test@example.com', 'test123')

    page.should have_content('Welcome, Bob!')
    page.should have_content('You have 10000 Plink Points.')

    Plink::UsersSocialProfileRecord.last.user_id.should == user.id

    page.should_not have_css('img[src="/assets/hero-gallery/TacoBell_1.jpg"]')
    page.should have_css('img[src="/assets/hero-gallery/bk2.jpg"]')
    page.should have_content('You really want this')

    page.find('.marker:nth-of-type(2)').click

    within '.left' do
      page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    end
    within '.right' do
      page.should have_css('img[src="/assets/hero-gallery/bk1.jpg"]')
    end

    within '.welcome-text' do
      page.should have_css 'span.redeemable'
    end

    click_on 'Wallet'

    page.execute_script('$.fx.off = true;')

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

        page.should have_content 'This offer is only available through 2/1/20'
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

    page.find('.slot.locked', match: :first).click

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
