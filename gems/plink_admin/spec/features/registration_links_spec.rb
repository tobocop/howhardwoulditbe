require 'spec_helper'

describe 'Registration Links' do
  let!(:affiliate) { create_affiliate(name: 'the first one') }
  let!(:campaign) { create_campaign(name: 'Limp Bizkit forever') }
  let!(:landing_page) { create_landing_page(name: 'cookie') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Registration Links'

    click_on 'Create New Registration Links'

    click_on 'Create'

    page.should have_content 'You cannot create links without affiliates'

    select 'the first one', from: 'affiliate_ids[]'
    select 'Limp Bizkit forever', from: 'campaign_id'
    select 'cookie', from: 'landing_page_ids[]'

    click_on 'Create'

    within '.registration_link-list' do
      within '.registration_link-item:nth-of-type(1)' do
        page.should have_content "#{affiliate.id} - the first one"
        page.should have_content "#{campaign.id} - Limp Bizkit forever"
        page.should have_content "#{landing_page.id} - cookie"
      end
    end
  end
end
