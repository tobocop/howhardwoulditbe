require 'spec_helper'

describe 'Companies' do
  let!(:advertiser) { create_advertiser(advertiser_name: 'bold and wavy') }
  let!(:sales_rep) { create_sales_rep(name: 'Bob Nolongermire') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword', sales: 1)
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Companies'

    click_on 'Create New Company'

    click_on 'Create'

    page.should have_content 'Company could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Vanity url can't be blank"
    end

    fill_in 'Name', with: 'Burger King'
    fill_in 'Vanity url', with: 'BK'

    click_on 'Create'

    page.should have_content 'Company created successfully'

    within '.company-list' do
      within 'tr.company-item:nth-of-type(1)' do
        page.should have_content 'Burger King'
        page.should have_content 'Yes'
        page.should have_content 'Bob Nolongermire'
        page.should have_content 'https://analytics.plink.com/BK'

        click_on 'Burger King'
      end
    end

    page.should have_content 'Edit Company'

    fill_in 'Name', with: 'The better company'

    click_on 'Update'

    page.should have_content 'Company updated'

    within '.company-list' do
      within 'tr.company-item:nth-of-type(1)' do
        page.should have_content 'The better company'
      end
    end
  end
end
