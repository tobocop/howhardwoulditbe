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

    within '.registration_link-list' do
      within 'tr.registration_link-item:nth-of-type(1)' do
        page.should have_content "#{affiliate.id} - the first one"
        page.should have_content "#{campaign.id} - Limp Bizkit forever"
        page.should have_content "#{landing_page_one.id} - cookie"
        page.should have_content 'mobile detection on'

        click_link "Edit"
      end
    end

    page.should have_content affiliate.name
    page.should have_content campaign.name
    page.should have_content 'URL:'

    find("#flow_type_normal").should be_checked
    find("#flow_type_facebook").should_not be_checked

    choose('Facebook Share')
    within '.facebook' do
      select 'monster', from: 'landing_page_ids[]'
      select 'hero', from: 'share_page_ids[]'
      uncheck 'Enable Mobile Detection'

      click_on 'Update'
    end

    page.should have_content 'Registration link updated'

    within '.registration_link-list' do
      within 'tr.registration_link-item:nth-of-type(1)' do
        page.should have_content "#{affiliate.id} - the first one"
        page.should have_content "#{campaign.id} - Limp Bizkit forever"
        page.should have_content "#{landing_page_two.id} - monster"
        page.should have_content 'mobile detection off'
        page.should have_content "#{share_page.id} - hero"

        Plink::SharePageRecord.stub_chain(:select, :joins, :where, :group, :order).
          and_return([{registration_link_id: 15, share_page_id: 1, shared: false, count: 3}])
        click_link 'Stats'
      end
    end

    page.should have_content "Share Results for registration link ID:"

    within '.registration-link-share-stats' do
      page.should have_content 'Share Page ID'
      page.should have_content '1'

      page.should have_content 'Shared?'
      page.should have_content 'Decline'

      page.should have_content 'Count'
      page.should have_content '3'
    end
  end
end
