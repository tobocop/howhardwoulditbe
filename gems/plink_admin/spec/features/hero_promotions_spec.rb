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

    click_on 'Create'

    within '.hero-promotions-list' do
      within '.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz'
        page.should have_content 'This promotion is awesome'
        page.should have_css "img[src='http://example.com/image']"
        page.should have_content '28'
      end
    end
  end
end
