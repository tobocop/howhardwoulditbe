require 'qa_spec_helper'

describe 'Logged out Home page' do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    visit '/'
  end

  subject {page}

  it {should have_text('view offers') }

  it 'should allow a guest to view all offers' do
    click_on 'view offers'
    page.should have_text('Earn Plink Points at these locations.')
  end

  it 'should allow a guest to view all rewards' do
    click_on 'view rewards'
    page.should have_text('Redeem Plink Points for these rewards')
  end

  it 'should allow a guest to send an email via the Contact Us form' do
    click_on 'Contact Us'
  end
end