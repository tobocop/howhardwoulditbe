require 'spec_helper'

describe 'searching for a bank', js: true, driver: :selenium do
  let!(:tupac_bank) { create_institution(name: 'Bank of Tupac', intuit_institution_id: 100000) }
  let!(:dmx_bank) { create_institution(name: 'DMX Bank', is_supported: true) }
  let!(:zz_top_bank) { create_institution(name: 'ZZ Top Bank', is_supported: false) }
  let!(:institution_authenticated_event_type) { create_event_type(name: Plink::EventTypeRecord.card_add_type) }
  let(:user) { create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png') }
  let!(:affiliate) { create_affiliate(card_add_pixel: 'my$userID$pixel') }
  let!(:virtual_currency) { create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100) }

  before do
    user.primary_virtual_currency = virtual_currency
    user.save!
    create_wallet(user_id: user.id)
  end

  it 'allows the user to search' do
    visit "/tracking/new?aid=#{affiliate.id}"
    sign_in('test@example.com', 'test123')

    page.should have_content "Enter your bank's name."
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    fill_in 'institution_name', with: ''
    click_on 'Search'

    page.should have_content 'Please provide a bank name or URL'
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    create_users_institution(institution_id: tupac_bank.id)
    create_users_institution(institution_id: tupac_bank.id)
    create_users_institution(institution_id: dmx_bank.id)

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.current_path.should == institution_search_results_path

    page.should have_content 'MOST COMMON'
    within '.banks:not(.result-list)' do
      page.should have_content 'Bank of Tupac'
      page.should have_content 'DMX Bank'
    end

    page.should have_content 'ALL RESULTS (1 MATCH)'
    within '.banks.result-list' do
      within '.font-italic.font-lightgray' do
        page.should have_content '* ZZ Top Bank'
      end
    end

    click_on 'Bank of Tupac'

    page.should have_content 'Please login to your Bank of Tupac account.'
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    fill_in 'auth_1', with: 'bad'
    fill_in 'auth_2', with: 'login_failures'

    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    page.should have_content 'Login error. Error on logon'
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    fill_in 'auth_1', with: 'tfa_text'
    fill_in 'auth_2', with: "stuff#{rand(10**7)}"

    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content 'Security Question 1'
    page.should have_content "Enter your first pet's name:"
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    fill_in 'mfa_question_1', with: 'fail'
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content 'Incorrect answer to multi-factor authentication challenge question. Incorrect answer to Challenge Question'

    fill_in 'auth_1', with: 'tfa_text'
    fill_in 'auth_2', with: "stuff#{rand(10**7)}"
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    fill_in 'mfa_question_1', with: 'succeed'
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content "Select the card you'd like to earn rewards with."
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.current_path.should == institution_selection_path
    page.should have_content 'Congratulations!'
    page.should have_content "my#{user.id}pixel"

    institution_authenticated_event = Plink::EventRecord.order('eventID desc').first
    institution_authenticated_event.event_type_id.should == institution_authenticated_event_type.id
    institution_authenticated_event.user_id.should == user.id
  end

  it 'allows users to complete image based MFAs' do
    sign_in('test@example.com', 'test123')

    page.should have_content "Enter your bank's name."

    page.current_path.should == institution_search_path

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.current_path.should == institution_search_results_path
    page.should have_content 'MOST COMMON'

    click_on 'Bank of Tupac'

    page.should have_content 'Please login to your Bank of Tupac account.'

    fill_in 'auth_1', with: 'tfa_image'
    fill_in 'auth_2', with: "stuff#{rand(10**7)}"

    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should_not have_content 'Security Question 1'
    page.should have_content 'Enter the word in the image below'

    fill_in 'mfa_question_1', with: 'dog'
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content "Select the card you'd like to earn rewards with."
  end

  context 'for a user that already has a card registered' do
    before do
      user = create_user(email: 'almostbob@example.com', password: 'test123', first_name: 'Almostbob', avatar_thumbnail_url: 'http://www.example.com/test.png')
      user.primary_virtual_currency = virtual_currency
      user.save!
      create_wallet(user_id: user.id)
    end

    it 'does not allow another user to register using the same institution and username' do
      sign_in('test@example.com', 'test123')
      page.should have_content "Enter your bank's name."

      fill_in 'institution_name', with: 'bank'
      click_on 'Search'

      page.should have_content 'MOST COMMON'
      click_on 'Bank of Tupac'
      fill_in 'auth_1', with: 'bobloblaw'
      fill_in 'auth_2', with: 'nohablaespanol'

      click_on 'Connect'

      page.should have_content 'Communicating with Bank of Tupac.'

      page.should have_content "Select the card you'd like to earn rewards with."

      click_on 'Log Out'

      sign_in('almostbob@example.com', 'test123')
      page.should have_content "Enter your bank's name."

      fill_in 'institution_name', with: 'bank'
      click_on 'Search'

      page.should have_content 'MOST COMMON'
      click_on 'Bank of Tupac'
      fill_in 'auth_1', with: 'bobloblaw'
      fill_in 'auth_2', with: 'lobslawbomb'

      click_on 'Connect'

      page.should have_content "Are you sure you haven't linked this account before?"
      page.should have_content 'An account with this information has already been created. If you believe there is an error, please contact Plink support.'
      page.should have_link 'Plink support.'
    end

    it 'allows a user to update their login credentials' do
      sign_in('test@example.com', 'test123')
      page.should have_content "Enter your bank's name."

      fill_in 'institution_name', with: 'bank'
      click_on 'Search'

      page.should have_content 'MOST COMMON'
      click_on 'Bank of Tupac'
      fill_in 'auth_1', with: 'bobloblaw'
      fill_in 'auth_2', with: 'nohablaespanol'

      click_on 'Connect'

      page.should have_content "Select the card you'd like to earn rewards with."

      within '.card-select-container:nth-of-type(1)' do
        click_on 'Select'
      end

      page.should have_content 'Congratulations!'
      visit '/account'

      click_link 'Update Login Info'

      page.should have_content 'Update your bank or credit card login info.'

      fill_in 'auth_1', with: 'tfa_text'
      fill_in 'auth_2', with: "mmmmbacon"

      click_on 'Connect'

      page.should have_content 'Security Question 1'
      page.should have_content "Enter your first pet's name:"

      fill_in 'mfa_question_1', with: 'succeed'

      click_on 'Connect'

      page.should have_content "You've successfully updated your Bank of Tupac account."
    end
  end
end
