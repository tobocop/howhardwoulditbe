require 'spec_helper'

describe 'Managing account' do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    user = create_user(email: 'user@example.com', password: 'pass1word')
    create_oauth_token(user_id: user.id)
    create_users_institution_account(user_id: user.id)
  end

  it 'allows a user to manage their account', js: true, driver: :selenium do
    sign_in('user@example.com', 'pass1word')

    click_link 'My Account'

    page.should have_link 'Link Card'
    page.should have_content 'Card Linked?: true'

    page.should have_content 'You have 0 Plink Points.'
    page.should have_content 'Lifetime balance: 0 Plink Points'

    page.should_not have_link 'Redeem'

    page.should have_css '#social-link-widget'
  end
end
