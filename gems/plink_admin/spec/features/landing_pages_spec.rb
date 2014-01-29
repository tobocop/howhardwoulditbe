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

    fill_in 'Name (required)', with: 'landing on awesome'
    fill_in 'Partial name', with: 'mypartial.haml.html'

    click_on 'Create'

    page.should have_content 'Landing page created successfully'

    within '.landing_page-list' do
      within 'tr.landing_page-item:nth-of-type(1)' do
        page.should have_content 'landing on awesome'
        page.should have_content 'HAML'
        page.should have_content 'mypartial.haml.html'

        click_on 'landing on awesome'
      end
    end

    page.should have_content 'Edit Landing Page'

    fill_in 'Name (required)', with: 'Updated landing page'
    fill_in 'Partial name', with: 'myupdatedpartial.haml.html'

    click_on 'Update'

    page.should have_content 'Landing page updated'

    within '.landing_page-list' do
      within 'tr.landing_page-item:nth-of-type(1)' do
        page.should have_content 'Updated landing page'
        page.should have_content 'myupdatedpartial.haml.html'
      end
    end

    click_on 'Create New Landing Page'

    choose 'CMS'

    click_on 'Create'

    page.should have_content 'Landing page could not be created'

    within '.alert-box.alert' do
      page.should have_content "Name can't be blank"
      page.should have_content "Background image url can't be blank"
      page.should have_content "Header text one can't be blank"
      page.should have_content "Sub header text one can't be blank"
      page.should have_content "Button text one can't be blank"
      page.should have_content "How plink works one text one can't be blank"
      page.should have_content "How plink works two text one can't be blank"
      page.should have_content "How plink works three text one can't be blank"
    end

    fill_in 'Name (required)', with: 'landing on new awesome'
    fill_in 'Background image url (https required)', with: 'https://example.png/'
    fill_in 'Header text one (required)', with: 'dummy text'
    fill_in 'Sub header text one (required)', with: 'dummy text'
    fill_in 'Join button text (required)', with: 'JOIN ALREADY'
    fill_in 'How plink works left - text one (required)', with: 'dummy text'
    fill_in 'How plink works center - text one (required)', with: 'dummy text'
    fill_in 'How plink works right - text one (required)', with: 'dummy text'

    click_on 'Create'

    page.should have_content 'Landing page created successfully'

    within '.landing_page-list' do
      within 'tr.landing_page-item:nth-of-type(2)' do
        page.should have_content 'landing on new awesome'
        page.should have_content 'CMS'
      end
    end
  end
end
