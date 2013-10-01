require 'spec_helper'

describe 'Share Pages' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Share Pages'

    click_on 'Create New Share Page'

    click_on 'Create'

    page.should have_content 'Share page could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Partial path can't be blank"
    end

    fill_in 'Name', with: 'sharing on awesome'
    fill_in 'Partial name', with: 'mypartial.haml.html'

    click_on 'Create'

    page.should have_content 'Share page created successfully'

    within '.share_page-list' do
      within '.share_page-item:nth-of-type(1)' do
        page.should have_content 'sharing on awesome'
        page.should have_content 'mypartial.haml.html'

        click_on 'sharing on awesome'
      end
    end

    page.should have_content 'Edit Share Page'

    fill_in 'Name', with: 'Updated share page'
    fill_in 'Partial name', with: 'myupdatedpartial.haml.html'

    click_on 'Update'

    page.should have_content 'Share page updated'

    within '.share_page-list' do
      within '.share_page-item:nth-of-type(1)' do
        page.should have_content 'Updated share page'
        page.should have_content 'myupdatedpartial.haml.html'
      end
    end
  end
end
