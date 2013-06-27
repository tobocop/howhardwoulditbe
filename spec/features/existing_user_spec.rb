require 'spec_helper'

describe 'user signs in' do
  before(:each) do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png')
    create_hero_promotion(image_url: '/assets/hero-gallery/7eleven_1.jpg', display_order: 1, title: 'You want this.')

    advertiser = create_advertiser(logo_url: '/assets/test/oldnavy.png')

    create_offer(advertiser_id: advertiser.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        create_offers_virtual_currency(
            virtual_currency_id: virtual_currency.id,
            tiers: [new_tier]
        )
    ])
  end

  it 'a registered user can have an active session', js: true do
    visit '/'

    click_on 'Sign In'

    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'test123'

    click_on 'Log in'

    current_path.should == '/dashboard'
    page.should have_content('Welcome, Bob!')
    page.should have_content('You have 0 Plink Points.')

    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_css('img[src="http://www.example.com/test.png"]')
    page.should have_content('You want this.')

    page.should have_css('#social-link-widget[gigid="showAddConnectionsUI"]')

    click_on 'Invite Friends'
    page.should have_css('[gigid="showShareUI"]')

    click_on 'Wallet'
    page.should have_css('img[src="/assets/hero-gallery/7eleven_1.jpg"]')
    page.should have_content('You want this.')
    page.should have_content 'Select From These Offers'
    page.should have_css 'img[src="/assets/test/oldnavy.png"]'

    click_on 'Log Out'

    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')
  end

end