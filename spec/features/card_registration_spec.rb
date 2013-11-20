require 'spec_helper'

describe 'searching for a bank', js: true do
  before do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    user = create_user(email: 'test@example.com', password: 'test123', first_name: 'Bob', avatar_thumbnail_url: 'http://www.example.com/test.png')
    wallet = create_wallet(user_id: user.id)
  end

  it 'allows the user to search' do
    sign_in('test@example.com', 'test123')

    page.should have_content "Enter your bank's name."
    page.current_path.should == institution_search_path

    fill_in 'institution_name', with: ''
    click_on 'Search'

    page.should have_content 'Please provide a bank name or URL'

    tupac_bank = create_institution(name: 'Bank of Tupac', intuit_institution_id: 100000)
    create_users_institution(institution_id: tupac_bank.id)
    create_users_institution(institution_id: tupac_bank.id)

    institutions = [
      tupac_bank,
      double(name: 'DMX Bank', institution_id: 12, is_supported?: true),
      double(name: 'ZZ Top Bank', institution_id: 13, is_supported?: false)
    ]
    Plink::InstitutionRecord.should_receive(:search).and_return(institutions)

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

    fill_in 'Banking Userid', with: "tfa_text"
    fill_in 'Banking Password', with: "stuff#{rand(10**7)}"

    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content 'Security Question 1'
    page.should have_content "Enter your first pet's name:"

    fill_in 'question_1', with: 'fail'
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content 'Incorrect answer to multi-factor authentication challenge question. Incorrect answer to Challenge Question'

    fill_in 'Banking Userid', with: "tfa_text"
    fill_in 'Banking Password', with: "stuff#{rand(10**7)}"
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    fill_in 'question_1', with: 'succeed'
    click_on 'Connect'

    page.should have_content 'Communicating with Bank of Tupac.'

    page.should have_content "Select the card you'd like to earn rewards with."
  end
end
