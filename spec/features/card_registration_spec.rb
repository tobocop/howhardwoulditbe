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

    tupac_bank = create_institution(name: 'Bank of Tupac')
    institutions = [
      tupac_bank,
      double(name: 'DMX Bank', institution_id: 12),
      double(name: 'ZZ Top Bank', institution_id: 13)
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
      page.should have_content 'ZZ Top Bank'
    end

    click_on 'Bank of Tupac'

    page.should have_content 'Please login to your Chase Bank account.'
  end
end
