require 'spec_helper'

describe 'Affiliates' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Affiliates'

    click_on 'Create New Affiliate'

    click_on 'Create'

    page.should have_content 'Affiliate could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'This is my affiliate'

    click_on 'Create'

    page.should have_content 'Affiliate created successfully'

    within '.affiliate-list' do
      within '.affiliate-item:nth-of-type(1)' do
        page.should have_content 'This is my affiliate'

        click_on 'This is my affiliate'
      end
    end

    page.should have_content 'Edit Affiliate'

    fill_in 'Name', with: 'The more awesome affiliate'

    click_on 'Update'

    page.should have_content 'Affiliate updated'

    within '.affiliate-list' do
      within '.affiliate-item:nth-of-type(1)' do
        page.should have_content 'The more awesome affiliate'
      end
    end
  end

  context 'edit' do
    let(:affiliate) { create_affiliate(name: 'the first one') }
    let(:campaign) { create_campaign(name: 'Limp Bizkit forever') }
    let(:landing_page_one) { create_landing_page(name: 'cookie') }
    let(:landing_page_two) { create_landing_page(name: 'monster') }
    let!(:registration_link) {
      create_registration_link(
        affiliate_id: affiliate.id,
        campaign_id: campaign.id,
        start_date: 1.day.ago.to_date,
        end_date: 1.day.from_now.to_date,
        is_active: true,
        landing_page_records: [landing_page_one, landing_page_two]
      )
    }

    it 'can view and edit registration links' do
      sign_in_admin(email: 'admin@example.com', password: 'pazzword')

      click_link 'Affiliates'
      click_link affiliate.name

      page.should have_content 'Associated Links'

      within '.registration_link-list' do
        within '.registration_link-item:nth-of-type(1)' do
          page.should have_content registration_link.id
          page.should have_content 'Limp Bizkit forever'
          page.should have_content 1.day.ago.to_date
          page.should have_content 1.day.from_now.to_date
          page.should have_content true

          click_link 'Edit'

          page.current_path.should == "/registration_links/#{registration_link.id}/edit"
        end
      end
    end
  end
end
