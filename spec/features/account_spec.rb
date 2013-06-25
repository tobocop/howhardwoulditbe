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
  end
end
