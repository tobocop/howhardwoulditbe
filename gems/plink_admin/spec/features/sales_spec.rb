require 'spec_helper'

describe 'Sales' do
  before do
    create_admin(email: 'admin@example.com', password: 'pazzword', sales: 1)
  end

  it 'lets a sales admin sign in' do
    sign_in_admin(email: 'admin@example.com', password:'pazzword')

    page.should_not have_content 'Hero Promotions'
    page.should_not have_content 'Find Users'
    page.should_not have_content 'Contests'
    page.should_not have_content 'Affiliates'
    page.should_not have_content 'Campaigns'
    page.should_not have_content 'Landing Pages'
    page.should_not have_content 'Share Pages'
    page.should_not have_content 'Registration Links'
    page.should_not have_content 'Offers'
    page.should_not have_content 'Tango'
    page.should_not have_content 'Global Login Tokens'

    page.should have_content 'Brands'
    page.should have_content 'Contacts'
    page.should have_content 'Import'
  end
end
