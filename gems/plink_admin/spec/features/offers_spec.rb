require 'spec_helper'

describe 'offers' do
  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')
    
    advertiser = create_advertiser(advertiser_name: 'borger king')
    create_offer(advertisers_rev_share: 0.08, advertiser_id: advertiser.id, start_date: '1900-01-01', end_date: 8.days.from_now)
  end

  it 'can have its expiration_date edited by admins' do
    click_link 'Offers'

    within '.offer-list' do
      within '.offer-item:nth-of-type(1)' do
        page.should have_content 'borger king'

        click_on 'Edit'
      end
    end

    select 7.days.from_now.day, from: 'offer[end_date(3i)]'

    click_on 'Update'

    page.should have_content 'Offer could not be updated. The end date for the offer needs to be at least 8 days from today.'

    select 1.year.from_now.year, from: 'offer[end_date(1i)]'

    click_on 'Update'

    page.should have_content 'Offer end date updated'

    within '.offer-list' do
      within '.offer-item:nth-of-type(1)' do
        page.should have_content 'borger king'
        page.should have_content '2014'
      end
    end
  end
end