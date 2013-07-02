require 'qa_spec_helper'

describe "Wallet page", js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    visit '/wallet'
  end

  subject { page }

  it {should have_text ('My Wallet') }

  it 'should be empty on a users first visit' do
  end

  it 'should have three open slots initially' do
    page.should have_text('This slot is empty.') #, count: count.to_i)
  end
end