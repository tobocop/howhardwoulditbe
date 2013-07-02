require 'qa_spec_helper'

describe "Wallet page", js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    visit '/wallet'
  end

  subject { page }

  it {should have_text ('Select From These Offers') }
end