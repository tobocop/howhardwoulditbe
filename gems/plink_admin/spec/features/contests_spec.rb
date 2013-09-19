require 'spec_helper'

describe 'Contests' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Contests'

    click_on 'Create New Contest'

    click_on 'Create'

    within '.alert-box.alert' do
      page.should have_content "Description can't be blank"
      page.should have_content "Image can't be blank"
      page.should have_content "Prize can't be blank"
      page.should have_content "Terms and conditions can't be blank"
    end

    fill_in 'Description', with: 'Awesome contest'
    fill_in 'Image URL', with: 'http://example.com/image.png'
    fill_in 'Prize', with: 'All of the bananas'
    fill_in 'Terms', with: 'You must defeat the banana hamrick'

    click_on 'Create'

    within '.contest-list' do
      within '.contest-item:nth-of-type(1)' do
        page.should have_content 'Awesome contest'
        page.should have_css "img[src='http://example.com/image.png']"
        page.should have_content 'All of the bananas'

        click_on 'Edit'
      end
    end

    page.should have_content 'Edit Contest'

    fill_in 'Description', with: 'The contest with more awesome'
    fill_in 'Image URL', with: 'http://example.com/explosions.png'
    fill_in 'Prize', with: 'Bombs'

    click_on 'Update'

    within '.contest-list' do
      within '.contest-item:nth-of-type(1)' do
        page.should have_content 'The contest with more awesome'
        page.should have_css "img[src='http://example.com/explosions.png']"
        page.should have_content 'Bombs'
      end
    end
  end
end
