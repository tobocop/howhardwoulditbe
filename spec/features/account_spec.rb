require 'spec_helper'

describe 'Managing account' do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'user@example.com', password: 'pass1word')
  end

  it 'allows a user to manage their account', js: true do
    sign_in('user@example.com', 'pass1word')

    click_link 'My Account'

    page.should have_link 'Link Card'
    page.should have_content 'Card Linked?: false'

    page.should have_content 'You have 0 Plink Points.'
    page.should have_content 'Lifetime balance: 0 Plink Points'

    page.should_not have_link 'Redeem'
  end
end
