require 'spec_helper'

describe 'Reverifying', js: true, driver: :selenium do
  let(:user) { create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob') }

  before do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    create_wallet(user_id: user.id)
    institution = create_institution(name: 'bank of awesome', is_supported: true, intuit_institution_id: 100000)
    create_event_type(name: Plink::EventTypeRecord.card_add_type)
    create_award_type(award_code: 'incentivizedAffiliateID')
  end

  it 'allows a user to reverify login credentials', :vcr do
    sign_in('test@example.com', 'test123')
    page.should have_content "Enter your bank's name."

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.should have_content 'MOST COMMON'
    click_on 'bank of awesome'
    fill_in 'auth_1', with: 'bobloblaw'
    fill_in 'auth_2', with: 'nohablaespanol'

    click_on 'Connect'

    page.should have_content "Select the card you'd like to earn rewards with."

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.should have_content 'Congratulations!'

    create_user_reverification(
      completed_on: nil,
      is_notification_successful: false,
      intuit_error_id: 103,
      user_id: user.id,
      users_institution_id: Plink::UsersInstitutionRecord.last.id
    )

    visit '/account'

    page.should have_content 'Inactive'
    page.should have_image 'icon_alert_pink.png'

    within '.content:nth-of-type(4)' do
      click_link 'Reconnect My Account'
    end

    page.should have_content 'Reconnect your bank or credit card to Plink.'

    fill_in 'auth_1', with: 'my_account'
    fill_in 'auth_2', with: 'willworknow'

    click_on 'Connect'

    page.should have_content "Next Steps"
    page.should have_content "You've successfully reconnected your bank of awesome account to your Plink account."

    visit '/account'
    page.should_not have_content 'Reconnect My Account'
  end

  it 'allows a user to reverify mfa questions', :vcr do
    sign_in('test@example.com', 'test123')
    page.should have_content "Enter your bank's name."

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.should have_content 'MOST COMMON'
    click_on 'bank of awesome'
    fill_in 'auth_1', with: 'bobloblaw'
    fill_in 'auth_2', with: 'nohablaespanol'

    click_on 'Connect'

    page.should have_content "Select the card you'd like to earn rewards with."

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.should have_content 'Congratulations!'

    create_user_reverification(
      completed_on: nil,
      is_notification_successful: false,
      intuit_error_id: 103,
      user_id: user.id,
      users_institution_id: Plink::UsersInstitutionRecord.last.id
    )

    visit '/account'

    within '.content:nth-of-type(9)' do
      click_link 'Reconnect My Account'
    end

    fill_in 'auth_1', with: 'tfa_text'
    fill_in 'auth_2', with: "mmmmbacon"

    click_on 'Connect'

    page.should have_content 'Security Question 1'
    page.should have_content "Enter your first pet's name:"

    fill_in 'mfa_question_1', with: 'succeed'

    click_on 'Connect'

    page.should have_content "You've successfully reconnected your bank of awesome account to your Plink account."

    visit '/account'
    page.should_not have_content 'Reconnect My Account'
  end
end
