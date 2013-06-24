require 'spec_helper'

describe 'user signs in' do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob')
    create_hero_promotion(image_url: '/assets/hero-gallery/7eleven_1.jpg', display_order: 1, title: 'You want this.')
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
    page.should have_content('You want this.')

    page.should have_css('#social-links[gigid="showAddConnectionsUI"]')

    click_on 'Log Out'

    current_path.should == '/'
    page.should have_content('You have been successfully logged out.')
  end
end