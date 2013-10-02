require 'spec_helper'

describe 'Contests' do

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')
  end

  it 'can be created by an admin' do
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

  it 'shows statistics' do
    PlinkAdmin::ContestQueryService.stub(:get_statistics).and_return({
      :entries=>
        [{"entry_source"=>"other",
          "admin_entries"=>"275",
          "facebook_entries"=>"160",
          "twitter_entries"=>"162",
          "total_entries"=>"597"}],
      :emails_and_linked_cards=>
        [{"registration_source"=>"facebook_entry_post",
          "email_captures"=>"4",
          "linked_cards"=>"2"},
         {"registration_source"=>"twitter_entry_post",
          "email_captures"=>"3",
          "linked_cards"=>"1"},
         {"registration_source"=>"other",
          "email_captures"=>"-",
          "linked_cards"=>"5"}]
    })
    contest = create_contest

    click_link 'Contests'

    click_link 'Statistics'

    page.should have_content'Entry Source'
    page.should have_content 'other'

    page.should have_content 'Facebook Entries'
    page.should have_content 160

    page.should have_content 'Twitter Entries'
    page.should have_content 162

    page.should have_content 'Admin Entries'
    page.should have_content 275

    page.should have_content 'Total Entries'
    page.should have_content 597

    page.should have_content 'Registration Source'
    page.should have_content 'Email Captures'
    page.should have_content 'Linked Cards'

    page.should have_content 'Facebook entry post'
    page.should have_content 4
    page.should have_content 2

    page.should have_content 'Twitter entry post'
    page.should have_content 3
    page.should have_content 1

    page.should have_content 'Other'
    page.should have_content '-'
    page.should have_content 5
  end
end
