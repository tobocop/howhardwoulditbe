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
      page.should have_content "Image url one can't be blank"
      page.should have_content "Name can't be blank"
    end

    fill_in 'Name', with: 'Heroz'
    fill_in 'Title', with: 'This promotion is awesome'
    fill_in 'Display Order', with: '28'
    check 'Active'
    fill_in 'Image URL (.jpg, .gif, etc) - Left', with: 'http://example.com/image'
    fill_in 'URL for image (admin provided, optional) - Left', with: 'http://example.com/'
    check 'Open left URL in same tab'
    fill_in 'Image URL (.jpg, .gif, etc, optional) - Right', with: 'http://example.com/image-right'
    fill_in 'URL for image (admin provided, optional) - Right', with: 'http://example.com/right'
    check 'Open right URL in same tab'
    check 'Show to linked members'
    check 'Show to non-linked members'

    click_on 'Create'

    hero_promotion = Plink::HeroPromotionRecord.last

    hero_promotion.link_one.should == 'http://example.com/'
    hero_promotion.link_two.should == 'http://example.com/right'
    within '.hero-promotions-list' do
      within 'tr.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz'
        page.should have_content 'This promotion is awesome'
        page.should have_css "img[src='http://example.com/image']"
        page.should have_css "img[src='http://example.com/image-right']"
        page.should have_content '28'
        page.should have_content 'Active'

        click_on 'Heroz'
      end
    end

    page.should have_content 'Edit Hero Promotion'

    fill_in 'Name', with: 'Heroz II'
    fill_in 'Title', with: 'This promotion is awesomer'
    fill_in 'Display Order', with: '25'
    uncheck 'Active'
    fill_in 'Image URL (.jpg, .gif, etc) - Left', with: 'http://example.com/new-image'
    fill_in 'URL for image (admin provided, optional) - Left', with: ''
    uncheck 'Open left URL in same tab'
    fill_in 'Image URL (.jpg, .gif, etc, optional) - Right', with: 'http://example.com/new-image-right'
    fill_in 'URL for image (admin provided, optional) - Right', with: 'new'
    uncheck 'Open right URL in same tab'
    uncheck 'Show to linked members'

    click_on 'Update'

    hero_promotion.reload.link_one.should be_blank
    hero_promotion.reload.link_two.should == 'new'
    within '.hero-promotions-list' do
      within 'tr.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz II'
        page.should have_content 'This promotion is awesomer'
        page.should have_content '25'
        page.should have_css "img[src='http://example.com/new-image']"
        page.should have_css "img[src='http://example.com/new-image-right']"
        page.should have_content 'Inactive'

        click_on 'Heroz II'
      end
    end

    page.should have_content 'Edit Hero Promotion'

    click_on 'Change Audience'

    page.current_path.should == "/hero_promotions/#{hero_promotion.id}/edit_audience"

    file = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/test.csv'), 'text/csv')
    attach_file('User IDs File', file.path)

    uncheck 'Show to non-linked members'

    click_on 'Submit'

    within '.hero-promotions-list' do
      within 'tr.hero-promotion-item:nth-of-type(1)' do
        page.should have_content 'Heroz II'
        page.should have_content 'This promotion is awesomer'
        page.should have_content '25'
        page.should have_css "img[src='http://example.com/new-image']"
        page.should have_content 'Inactive'
      end
    end
  end
end
