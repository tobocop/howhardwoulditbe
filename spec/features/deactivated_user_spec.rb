require 'spec_helper'

describe 'force deactivated users' do
  before do
    currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    create_user(is_force_deactivated:true, email:'test@example.com', password:'test123')
  end

  it 'does not allow them to login', js: true do
    sign_in('test@example.com', 'test123')
    page.should have_content('Sorry, the email and password do not match for this account. Please try again.')
  end
end
