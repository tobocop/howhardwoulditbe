require 'spec_helper'

describe 'searching for a bank', js: true, driver: :selenium do
  let!(:tupac_bank) { create_institution(name: 'Bank of Tupac', intuit_institution_id: 100000) }
  let!(:dmx_bank) { create_institution(name: 'DMX Bank', is_supported: true, intuit_institution_id: 300002) }
  let!(:zz_top_bank) { create_institution(name: 'ZZ Top Bank', is_supported: false) }
  let!(:institution_authenticated_event_type) { create_event_type(name: Plink::EventTypeRecord.card_add_type) }
  let(:user) { create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png') }
  let!(:virtual_currency) { create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100) }
  let!(:affiliate) {
    create_affiliate(
      card_add_pixel: 'my$userID$pixel',
      has_incented_card_registration: true,
      card_registration_dollar_award_amount: 2.34
    )
  }

  before do
    user.primary_virtual_currency = virtual_currency
    user.save!
    create_award_type(award_code: 'incentivizedAffiliateID')
    create_award_type(award_code: 'friendReferral')
    create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id)
    create_wallet(user_id: user.id)
  end

  it 'allows the user to search', :vcr do
    user_two = create_user(email: 'iamreferring@plink.com', password: 'test123', first_name: 'Bobby')
    create_users_virtual_currency(user_id: user_two.id, virtual_currency_id: virtual_currency.id)
    wallet = create_wallet(user_id: user_two.id)
    create_locked_wallet_item(wallet_id: wallet.id)

    visit "/refer/#{user_two.id}/aid/#{affiliate.id}/"

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
    page.should have_content 'MY VISA'
    page.should have_content '7777'
    page.should have_xpath('//img[@src="/assets/home_security_truste.png"]')

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.should have_content 'Congratulations!'
    page.should have_content "my#{user.id}pixel"
    page.current_path.should == '/institutions/congratulations'

    page.should have_content 'You have 234 Plink Points.'

    institution_authenticated_event = Plink::EventRecord.order('eventID desc').first
    institution_authenticated_event.event_type_id.should == institution_authenticated_event_type.id
    institution_authenticated_event.user_id.should == user.id

    click_on 'Log Out'

    sign_in('iamreferring@plink.com', 'test123')

    page.should have_content('Welcome, Bobby!')
    page.should have_content('You have 100 Plink Points.')

    click_on 'Wallet'
    page.should have_content 'This slot is empty.'
  end

  it 'allows users to complete image based MFAs', :vcr do
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

  it 'verifies that a users account has transactions', :vcr do
    sign_in('test@example.com', 'test123')

    page.should have_content "Enter your bank's name."

    page.current_path.should == institution_search_path

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.current_path.should == institution_search_results_path
    page.should have_content 'MOST COMMON'

    click_on 'Bank of Tupac'

    page.should have_content 'Please login to your Bank of Tupac account.'

    fill_in 'auth_1', with: 'anything'
    fill_in 'auth_2', with: "stuff#{rand(10**7)}"

    click_on 'Connect'

    page.should have_content "Select the card you'd like to earn rewards with."

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.should have_content 'The account you selected is inelligible.'
  end

  it 'changes the congratulations link if a user came from a contest', :vcr do
    contest = create_contest(
      description: 'This is the best contest ever',
      end_time: 1.day.from_now.to_date,
      image: '/assets/profile.jpg',
      non_linked_image: '/assets/icon_active.png',
      prize: 'The prize is a new car',
      start_time: 1.day.ago.to_date,
      terms_and_conditions: 'These are terms and conditions'
    )

    sign_in('test@example.com', 'test123')

    page.should have_content "Enter your bank's name."

    visit contests_path

    click_link 'LINK YOUR CARD'

    page.should have_content "Enter your bank's name."

    page.current_path.should == institution_search_path

    fill_in 'institution_name', with: 'bank'
    click_on 'Search'

    page.current_path.should == institution_search_results_path
    page.should have_content 'MOST COMMON'

    click_on 'Bank of Tupac'

    page.should have_content 'Please login to your Bank of Tupac account.'

    fill_in 'auth_1', with: 'anything'
    fill_in 'auth_2', with: "stuff#{rand(10**7)}"

    click_on 'Connect'

    page.should have_content "Select the card you'd like to earn rewards with."

    within '.card-select-container:nth-of-type(1)' do
      click_on 'Select'
    end

    page.should have_content "We're making sure the account you've selected is eligible for the Plink program. This will only take a few moments."

    page.should have_content "You've successfully linked your"

    page.should have_content "You'll now earn 5X entries every time you enter a contest."
    click_link 'Go to This is the best contest ever'

    page.should have_content "Congratulations! You'll now earn 5X the entries.  Don't forget to add your favorite stores and restaurants to your Wallet and earn rewards for all your purchases."
  end

  it 'allows users with an account type of Other to set their account type', :vcr do
    sign_in('test@example.com', 'test123')

    fill_in 'institution_name', with: 'Bank'
    click_on 'Search'

    page.should have_content 'MOST COMMON'

    click_on 'DMX Bank'

    page.should have_content 'Please login to your DMX Bank account.'

    fill_in 'auth_1', with: 'other_account'
    fill_in 'auth_2', with: 'go'

    click_on 'Connect'

    page.should have_content 'Communicating with DMX Bank.'

    click_on 'Select'

    page.should have_content 'What type of account is this?'
    page.should have_content 'Plink will only work with a credit or a debit account.'
    page.should have_link 'Contact support.'

    click_on 'Credit'

    page.should have_content 'Checking account compatibility...'
    page.should have_content "We're making sure the account you've selected is eligible for the Plink program. This will only take a few moments."

    page.should have_content "You've successfully linked your My Unknown to your Plink account."
  end

  context 'for a user that already has a card registered' do
    before do
      user = create_user(email: 'almostbob@example.com', password: 'test123', first_name: 'Almostbob', avatar_thumbnail_url: 'http://www.example.com/test.png')
      user.primary_virtual_currency = virtual_currency
      user.save!
      create_wallet(user_id: user.id)
    end

    it 'does not allow another user to register using the same institution and username', :vcr do
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

    it 'allows a user to update their login credentials', :vcr do
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
