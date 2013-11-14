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
        page.should have_content 'All'

        click_on 'Heroz'
      end
    end

    page.should have_content 'Edit Hero Promotion'

    fill_in 'Name', with: 'Heroz II'
    fill_in 'Title', with: 'This promotion is awesomer'
    fill_in 'Display Order', with: '25'
    fill_in 'Image URL', with: 'http://example.com/new-image'
    uncheck 'Active'
    uncheck 'Show to linked members'

    click_on 'Update'

    within '.hero-promotions-list' do
      within '.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz II'
        page.should have_content 'This promotion is awesomer'
        page.should have_content '25'
        page.should have_css "img[src='http://example.com/new-image']"
        page.should have_content 'Inactive'
        page.should have_content 'Non-Linked Users'

        click_on 'Heroz II'
      end
    end

    page.should have_content 'Edit Hero Promotion'

    click_on 'Change Audience'

    hero_promotion = Plink::HeroPromotionRecord.last
    page.current_path.should == "/hero_promotions/#{hero_promotion.id}/edit_audience"

    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'), 'text/csv')
    attach_file('User IDs File', file.path)

    uncheck 'Show to non-linked members'

    click_on 'Submit'

    within '.hero-promotions-list' do
      within '.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz II'
        page.should have_content 'This promotion is awesomer'
        page.should have_content '25'
        page.should have_css "img[src='http://example.com/new-image']"
        page.should have_content 'Inactive'
        page.should have_content 'List of Users'
      end
    end
  end
end
