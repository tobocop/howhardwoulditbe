require 'spec_helper'

describe 'Contacts' do
  let!(:advertiser) { create_advertiser(advertiser_name: 'bold and wavy') }
  let!(:sales_rep) { create_sales_rep(name: 'Bob Nolongermire') }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword', sales: 1)
    create_brand(name: 'only brand in the universe')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Contacts'

    click_on 'Create New Contact'

    click_on 'Create'

    page.should have_content 'Contact could not be created'

    within '.alert-box.alert' do
      page.should have_content "First name can't be blank"
      page.should have_content "Last name can't be blank"
      page.should have_content "Email can't be blank"
    end

    fill_in 'First name', with: 'Bob'
    fill_in 'Last name', with: 'King'
    fill_in 'Email', with: 'doingit@right.com'

    click_on 'Create'

    page.should have_content 'Contact created successfully'

    within '.contact-list' do
      within 'tr.contact-item:nth-of-type(1)' do
        page.should have_content 'Bob King'
        page.should have_content 'doingit@right.com'
        page.should have_content 'only brand in the universe'

        click_on 'Bob King'
      end
    end

    page.should have_content 'Edit Contact'

    fill_in 'First name', with: 'Jerry'

    click_on 'Update'

    page.should have_content 'Contact updated'

    within '.contact-list' do
      within 'tr.contact-item:nth-of-type(1)' do
        page.should have_content 'Jerry'
      end
    end
  end
end
