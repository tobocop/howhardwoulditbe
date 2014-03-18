require 'spec_helper'

describe 'Pending Jobs' do
  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Fishy Jobs'

    click_on 'Queue Fishy Fix'

    click_on 'Create'

    page.should have_content 'Fishy job could not be created'

    within '.alert-box.alert' do
      page.should have_content "Begin user can't be blank"
      page.should have_content "End user can't be blank"
    end

    fill_in 'Primary user id', with: '2'
    fill_in 'Fishy user id', with: '8'

    click_on 'Create'

    page.should have_content 'Fishy job created successfully'

    within '.fishy-list' do
      within 'tr.fishy-item:nth-of-type(1)' do
        page.should have_content '2'
        page.should have_content '8'
        page.should have_content 'Pending'
      end
    end
  end
end
