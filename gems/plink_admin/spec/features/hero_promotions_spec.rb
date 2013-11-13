require 'spec_helper'

describe 'Hero Promotions' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Hero Promotions'

    click_on 'Create New Hero Promotion'

    click_on 'Create'

    within '.alert-box.alert' do
      page.should have_content "Title can't be blank"
      page.should have_content "Image url can't be blank"
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'Heroz'
    fill_in 'Title', with: 'This promotion is awesome'
    fill_in 'Display Order', with: '28'
    check 'Active'
    fill_in 'Image URL', with: 'http://example.com/image'

    check 'Show to linked members'
    check 'Show to non-linked members'

    click_on 'Create'

    within '.hero-promotions-list' do
      within '.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz'
        page.should have_content 'This promotion is awesome'
        page.should have_css "img[src='http://example.com/image']"
        page.should have_content '28'
        page.should have_content 'Active'

        click_on 'Heroz'
      end
    end

    page.should have_content 'Edit Hero Promotion'

    fill_in 'Name', with: 'Heroz II'
    fill_in 'Title', with: 'This promotion is awesomer'
    fill_in 'Display Order', with: '25'
    fill_in 'Image URL', with: 'http://example.com/new-image'
    uncheck 'Active'

    click_on 'Update'

    within '.hero-promotions-list' do
      within '.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz II'
        page.should have_content 'This promotion is awesomer'
        page.should have_content '25'
        page.should have_css "img[src='http://example.com/new-image']"
        page.should have_content 'Inactive'
      end
    end
  end
end
