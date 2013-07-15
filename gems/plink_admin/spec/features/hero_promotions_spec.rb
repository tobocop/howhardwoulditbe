require 'spec_helper'

describe 'Hero Promotions' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be create by an admins' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_link 'Hero Promotions'

    click_on 'Create New Hero Promotion'

    click_on 'Create'

    within '.alert-box.alert' do
      page.should have_content "Title can't be blank"
      page.should have_content "Image url can't be blank"
    end

    fill_in 'Name', with: 'Heroz'
    fill_in 'Title', with: 'This promotion is awesome'
    fill_in 'Display Order', with: '28'
    check 'Active'
    fill_in 'Image URL', with: 'http://example.com/image'

    click_on 'Create'

  end
end
