require 'spec_helper'

describe 'Campaigns' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Campaigns'

    click_on 'Create New Campaign'

    click_on 'Create'

    page.should have_content 'Campaign could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'My Campaign'

    click_on 'Create'

    page.should have_content 'Campaign created successfully'

    within '.campaign-list' do
      within 'tr.campaign-item:nth-of-type(1)' do
        page.should have_content 'My Campaign'

        click_on 'My Campaign'
      end
    end

    page.should have_content 'Edit Campaign'

    fill_in 'Name', with: 'The better campaign'

    click_on 'Update'

    page.should have_content 'Campaign updated'

    within '.campaign-list' do
      within 'tr.campaign-item:nth-of-type(1)' do
        page.should have_content 'The better campaign'
      end
    end
  end
end
