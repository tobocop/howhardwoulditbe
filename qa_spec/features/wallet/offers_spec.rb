require 'qa_spec_helper'

describe "Offers on wallet page", js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    visit '/wallet'
  end

  subject { page }

  it {should have_text ('Select From These Offers') }

  it 'should display all available offers' do
    #Make sure the results of this query are on the page:
    #  SELECT Offers.advertiserID, Advertisers.advertiserName FROM Offers
    #  INNER JOIN advertisers
    #  ON Offers.advertiserID=advertisers.advertiserID
    #  WHERE Offers.isActive = 1
  end

  it 'should display offer details modal when clicked' do
    click_on 'ADD TO WALLET'
    page.should have_link('ADD TO MY WALLET')
  end


end