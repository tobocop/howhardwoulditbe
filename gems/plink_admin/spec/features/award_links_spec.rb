require 'spec_helper'

describe 'Award Links' do

  before do
    create_award_type
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Award Links'

    click_on 'Create New Award Link'

    click_on 'Create'

    page.should have_content 'Award link could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Redirect url can't be blank"
    end

    fill_in 'Name', with: 'My Award Link'
    fill_in 'Redirect url', with: '/derp'

    click_on 'Create'

    page.should have_content 'Award link created successfully'

    within '.award_link-list' do
      within 'tr.award_link-item:nth-of-type(1)' do
        page.should have_content 'My Award Link'

        click_on 'My Award Link'
      end
    end

    page.should have_content 'Edit Award Link'

    fill_in 'Name', with: 'The better Award Link'

    click_on 'Update'

    page.should have_content 'Award link updated'

    within '.award_link-list' do
      within 'tr.award_link-item:nth-of-type(1)' do
        page.should have_content 'The better Award Link'
      end
    end
  end
end
