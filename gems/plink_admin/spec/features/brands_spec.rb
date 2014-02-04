require 'spec_helper'

describe 'Brands' do
  let!(:advertiser) { create_advertiser(advertiser_name: 'bold and wavy') }
  let!(:sales_rep) { create_sales_rep(name: 'Bob Nolongermire') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword', sales: 1)
    create_brand(name: 'competing brand 1', sales_rep: sales_rep)
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Brands'

    click_on 'Create New Brand'

    click_on 'Create'

    page.should have_content 'Brand could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Vanity url can't be blank"
    end

    fill_in 'Name', with: 'Burger King'
    fill_in 'Vanity url', with: 'BK'
    check 'competing brand 1'

    click_on 'Create'

    page.should have_content 'Brand created successfully'

    within '.brand-list' do
      within 'tr.brand-item:nth-of-type(2)' do
        page.should have_content 'Burger King'
        page.should have_content 'Yes'
        page.should have_content 'Bob Nolongermire'
        page.should have_content 'https://analytics.plink.com/BK'

        click_on 'Burger King'
      end
    end

    page.should have_content 'Edit Brand'
    page.should have_content 'Brands contacts'

    fill_in 'Name', with: 'The better brand'

    click_on 'Update'

    page.should have_content 'Brand updated'

    within '.brand-list' do
      within 'tr.brand-item:nth-of-type(2)' do
        page.should have_content 'The better brand'
      end
    end
  end
end
