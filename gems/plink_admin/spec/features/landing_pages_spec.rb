require 'spec_helper'

describe 'Landing Pages' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Landing Pages'

    click_on 'Create New Landing Page'

    click_on 'Create'

    page.should have_content 'Landing page could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Partial path can't be blank"
    end

    fill_in 'Name', with: 'landing on awesome'
    fill_in 'Partial name', with: 'mypartial.haml.html'

    click_on 'Create'

    page.should have_content 'Landing page created successfully'

    within '.landing_page-list' do
      within 'tr.landing_page-item:nth-of-type(1)' do
        page.should have_content 'landing on awesome'
        page.should have_content 'mypartial.haml.html'

        click_on 'landing on awesome'
      end
    end

    page.should have_content 'Edit Landing Page'

    fill_in 'Name', with: 'Updated landing page'
    fill_in 'Partial name', with: 'myupdatedpartial.haml.html'

    click_on 'Update'

    page.should have_content 'Landing page updated'

    within '.landing_page-list' do
      within 'tr.landing_page-item:nth-of-type(1)' do
        page.should have_content 'Updated landing page'
        page.should have_content 'myupdatedpartial.haml.html'
      end
    end
  end
end
