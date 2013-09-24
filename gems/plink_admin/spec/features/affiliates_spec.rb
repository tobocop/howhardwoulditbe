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

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'This is my affiliate'

    click_on 'Create'

    within '.affiliate-list' do
      within '.affiliate-item:nth-of-type(1)' do
        page.should have_content 'This is my affiliate'

        click_on 'This is my affiliate'
      end
    end

    page.should have_content 'Edit Affiliate'

    fill_in 'Name', with: 'The more awesome affiliate'

    click_on 'Update'

    within '.affiliate-list' do
      within '.affiliate-item:nth-of-type(1)' do
        page.should have_content 'The more awesome affiliate'
      end
    end
  end
end
