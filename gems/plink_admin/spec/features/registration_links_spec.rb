require 'spec_helper'

describe 'Registration Links' do
  let!(:affiliate) { create_affiliate(name: 'the first one') }
  let!(:campaign) { create_campaign(name: 'Limp Bizkit forever') }
  let!(:landing_page_one) { create_landing_page(name: 'cookie') }
  let!(:landing_page_two) { create_landing_page(name: 'monster') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Registration Links'

    click_on 'Create New Registration Links'

    click_on 'Create'

    page.should have_content 'Failed to create one or more registration links'

    within '.alert-box.alert' do
      page.should have_content 'You cannot create links without selecting an affiliate'
    end

    select 'the first one', from: 'affiliate_ids[]'
    select 'Limp Bizkit forever', from: 'campaign_id'
    select 'cookie', from: 'landing_page_ids[]'

    click_on 'Create'

    page.should have_content 'Successfully created one or more registration links'

    within '.registration_link-list' do
      within '.registration_link-item:nth-of-type(1)' do
        page.should have_content "#{affiliate.id} - the first one"
        page.should have_content "#{campaign.id} - Limp Bizkit forever"
        page.should have_content "#{landing_page_one.id} - cookie"

        click_link "Edit"
      end
    end

    page.should have_content affiliate.name
    page.should have_content campaign.name
    page.should have_content 'Registration Link:'

    select 'monster', from: 'landing_page_ids[]'

    click_on 'Update'

    page.should have_content 'Registration link updated'

    within '.registration_link-list' do
      within '.registration_link-item:nth-of-type(1)' do
        page.should have_content "#{affiliate.id} - the first one"
        page.should have_content "#{campaign.id} - Limp Bizkit forever"
        page.should have_content "#{landing_page_two.id} - monster"
      end
    end
  end
end
