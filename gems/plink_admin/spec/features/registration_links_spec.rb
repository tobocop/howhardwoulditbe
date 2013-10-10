require 'spec_helper'

describe 'Registration Links' do
  let!(:affiliate) { create_affiliate(name: 'the first one') }
  let!(:campaign) { create_campaign(name: 'Limp Bizkit forever') }
  let!(:landing_page_one) { create_landing_page(name: 'cookie') }
  let!(:landing_page_two) { create_landing_page(name: 'monster') }
  let!(:share_page) { create_share_page(name: 'hero') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do #, js: true do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Registration Links'

    click_on 'Create New Registration Links'

    choose('Normal')
    within '.normal' do
      click_on 'Create'
    end

    page.should have_content 'Failed to create any registration links'

    within '.alert-box.alert' do
      page.should have_content 'Please select an affiliate'
    end

    within '.normal' do
      select 'the first one', from: 'affiliate_ids[]'
      select 'Limp Bizkit forever', from: 'campaign_id'
      select 'cookie', from: 'landing_page_ids[]'

      click_on 'Create'
    end

    page.should have_content 'Successfully created 1 registration link(s)'

    click_on 'Create New Registration Links'

    choose('Facebook Share')
    within '.facebook' do
      click_on 'Create'
    end

    page.should have_content 'Failed to create any registration links'

    within '.alert-box.alert' do
      page.should have_content 'Please select an affiliate'
    end

    within '.facebook' do
      select 'the first one', from: 'affiliate_ids[]'
      select 'Limp Bizkit forever', from: 'campaign_id'
      select 'cookie', from: 'landing_page_ids[]'
      select 'hero', from: 'share_page_ids[]'

      click_on 'Create'
    end

    page.should have_content 'Successfully created 1 registration link(s)'

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
    page.should have_content 'URL:'

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
