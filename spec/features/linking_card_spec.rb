require 'spec_helper'

describe 'Linking a card' do
  before do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    user = create_user(email: 'user@example.com', password: 'pass1word')
    create_wallet(user_id: user.id)
    old_navy = create_advertiser(logo_url: '/assets/test/oldnavy.png', advertiser_name: 'Old Navy')

    @old_navy_offer = create_offer(advertiser_id: old_navy.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: virtual_currency.id,
            tiers: [new_tier]
        )
    ])
  end

  it 'allows a user without a linked card to add one from the offer details modal', js: true, driver: :selenium do
    sign_in('user@example.com', 'pass1word')

    click_on 'Wallet'

    page.execute_script('$.fx.off = true;')

    click_on 'Add to wallet'

    within '.modal' do
      page.should have_content 'Link Your Card'
      click_on 'Link Your Card'
    end

    page.current_path.should == '/account'

    page.should have_css '#card-add-modal'
  end
end
