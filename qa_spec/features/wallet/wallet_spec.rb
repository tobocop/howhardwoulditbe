require 'qa_spec_helper'

describe "Wallet page", js: true do
  before(:each) do
    @virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    add_five_offers_to_page

    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")

    @user = Plink::User.where(emailAddress: "email@Plink.com").first
  end

  subject { page }

  context 'upon a users first visit' do
    it 'should have three open slots initially' do
      visit '/wallet'
      page.should have_css('h3', text: 'This slot is empty', count: 3)
    end

    it 'should have one locked slot before an offer is completed' do
      visit '/wallet'
      page.should have_css('h3', text: 'This slot is locked.')
      page.should have_css('h3', text: 'Complete an offer to unlock this slot.')
    end

    it 'should have one locked slot before a friend is referred' do
      pending 'Awaiting Implementation' do
        visit '/wallet'
        page.should have_css('h3', text: 'This slot is locked.')
        page.should have_css('h3', text: 'Refer a friend to unlock this slot.')
      end
    end
  end


  context 'before a user has linked a card' do
    it 'should prompt the user to link a card on the offer details modal' do
      visit '/wallet'  
      click_on('Add to wallet', match: :first)
      within '.modal' do
        click_on 'Link Your Card'
      end
      page.should have_css '#card-add-modal'
    end

    it 'should not allow the user to add an offer to the wallet' do
      visit '/wallet'
      click_on('Add to wallet', match: :first)
      within '.modal' do
        page.should_not have_link('Add to wallet')
      end
    end
  end


  context 'after a user has linked a card' do
    before(:each) do
      link_card_for_user(@user.userID)
      visit '/wallet'
    end

    it 'should allow the user to add an offer to the wallet' do
      click_on('Add to wallet', match: :first)
      within '.modal' do
        click_on 'Add To My Wallet'
      end
      page.should have_css('h3', text: 'This slot is empty', count: 2)
      page.should have_image('oldnavy', count: 1)
    end

    it 'should allow a user to remove an offer from the wallet' do
      click_on('Add to wallet', match: :first)
      within '.modal' do
        click_on 'Add To My Wallet'
      end
      click_on 'Remove'
      page.should have_css('h3', text: 'This slot is empty', count: 3)
    end
  end
end


def add_five_offers_to_page
  old_navy = create_advertiser(logo_url: '/assets/test/oldnavy.png', advertiser_name: 'Old Navy')
  @old_navy_offer = create_offer(advertiser_id: old_navy.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: @virtual_currency.id,
            tiers: [new_tier]
        )
    ])

  burger_king = create_advertiser(logo_url: '/assets/test/burgerking.png', advertiser_name: 'Burger King')
  @old_navy_offer = create_offer(advertiser_id: burger_king.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: @virtual_currency.id,
            tiers: [new_tier]
        )
    ])

  arbys = create_advertiser(logo_url: '/assets/wallet-logos/arbys.png', advertiser_name: 'Arbys')
  @arbys_offer = create_offer(advertiser_id: arbys.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: @virtual_currency.id,
            tiers: [new_tier]
        )
    ])

  dunkin = create_advertiser(logo_url: '/assets/wallet-logos/dunkindonuts.png', advertiser_name: 'Dunkin')
  @dunkin_offer = create_offer(advertiser_id: dunkin.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: @virtual_currency.id,
            tiers: [new_tier]
        )
    ])

  gap = create_advertiser(logo_url: '/assets/wallet-logos/gap.png', advertiser_name: 'Gap')
  @gap_offer = create_offer(advertiser_id: gap.id, start_date: Date.yesterday, end_date: Date.tomorrow, is_active: true, show_on_wall: true, offers_virtual_currencies: [
        new_offers_virtual_currency(
            virtual_currency_id: @virtual_currency.id,
            tiers: [new_tier]
        )
    ])
end










