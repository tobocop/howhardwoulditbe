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
      page.should have_content "Entry post title can't be blank"
      page.should have_content "Entry post body can't be blank"
      page.should have_content "Winning post title can't be blank"
      page.should have_content "Winning post body can't be blank"
    end

    fill_in 'Description', with: 'Awesome contest'
    fill_in 'Image URL', with: 'http://example.com/image.png'
    fill_in 'Non Linked Image URL', with: 'http://example.com/image_2.png'
    fill_in 'Grand Prize', with: 'All of the bananas'
    fill_in 'Prize Description', with: 'describe your prize'
    fill_in 'Terms', with: 'You must defeat the banana hamrick'
    fill_in 'Disclaimer Text', with: 'The last payment must be made in WAMPUM'

    select(1.year.from_now.year.to_s, :from => 'contest_end_time_1i')

    fill_in 'Header Text', with: 'im bigger than the rest of the text'
    fill_in 'Bold Text', with: 'im bolder than the rest of the text'
    fill_in 'Body Text', with: 'im smaller than the rest of the text'
    fill_in 'Share Button Text', with: 'share me'
    fill_in 'Reg Link Text', with: 'register me'

    fill_in 'Entry Post Title', with: 'sweet contest'
    fill_in 'Entry Post Body', with: 'enter the contest'
    fill_in 'Winning Post Title', with: 'sweet contest'
    fill_in 'Winning Post Body', with: 'enter the contest'
    fill_in 'In-App Notification', with: 'enter today, or else...'

    click_on 'Create'

    within '.contest-list' do
      within 'tr.contest-item:nth-of-type(1)' do
        page.should have_content 'Awesome contest'
        page.should have_css "img[src='http://example.com/image.png']"
        page.should have_css "img[src='http://example.com/image_2.png']"
        page.should have_content 'All of the bananas'

        click_on 'Edit'
      end
    end

    page.should have_content 'Edit Contest'

    fill_in 'Description', with: 'The contest with more awesome'
    fill_in 'Image URL', with: 'http://example.com/explosions.png'
    fill_in 'Grand Prize', with: 'Bombs'

    click_on 'Update'

    within '.contest-list' do
      within 'tr.contest-item:nth-of-type(1)' do
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
          "email_captures"=>nil,
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
    page.should have_content 'N/A'
    page.should have_content 5
  end

  it 'allows the admin to remove users who should not be able to win the contest' do
    contest = create_contest(end_time: 1.day.from_now)
    user = create_user
    entry = create_entry(user_id: user.id, contest_id: contest.id)
    contest.update_attributes(end_time: Time.zone.now)
    prize_level = create_contest_prize_level(contest_id: contest.id)
    winner = create_contest_winner(user_id: user.id, contest_id: contest.id, prize_level_id: prize_level.id)
    other_winner = create_contest_winner(user_id: user.id, contest_id: contest.id, prize_level_id: prize_level.id)

    click_link 'Contests'

    click_link 'Accept'

    page.should have_content 'Winners [2]'
    page.should have_button 'Select As Winners'

    first('.js-remove-contest-winner').click
    current_path.should == "/contests/#{contest.id}/remove_winner"
  end
end
