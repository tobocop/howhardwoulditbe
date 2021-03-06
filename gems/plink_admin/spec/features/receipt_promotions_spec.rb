require 'spec_helper'

describe 'Receipt promotions' do
  let!(:advertiser) { create_advertiser(advertiser_name: 'Taco Derp') }
  let!(:award_type) { create_award_type(award_code: 'code', dollar_amount: '2.33') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    create_registration_link(
      landing_page_records: [new_landing_page],
      affiliate_record: new_affiliate,
      campaign_record: new_campaign
    )
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Receipt Promotions'

    click_on 'Create New Receipt Promotion'

    click_on 'Create'

    page.should have_content 'Receipt promotion could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'My receipt promotion'
    fill_in 'Description', with: 'desc'
    fill_in 'Postback url', with: 'https://pixels.plink.com'
    select "Taco Derp (#{advertiser.id})", from: 'receipt_promotion[advertiser_id]'
    select "code - $2.33 (#{award_type.id})", from: 'receipt_promotion[award_type_id]'

    click_on 'Create'

    page.should have_content 'Receipt promotion created successfully'

    within '.receipt_promotion-list' do
      within 'tr.receipt_promotion-item:nth-of-type(1)' do
        page.should have_content 'My receipt promotion'

        click_on 'My receipt promotion'
      end
    end

    page.should have_content 'Edit Receipt Promotion'

    fill_in 'Name', with: 'The better receipt promotion'

    click_on 'Update'

    page.should have_content 'Receipt promotion updated'

    within '.receipt_promotion-list' do
      within 'tr.receipt_promotion-item:nth-of-type(1)' do
        page.should have_content 'The better receipt promotion'
      end
    end
  end
end
