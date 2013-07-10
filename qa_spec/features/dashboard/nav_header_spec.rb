require 'qa_spec_helper'

describe 'Nav Header' do #, js: true do
  before do
    login_new_user
  end

  describe 'should have the correct content' do
    subject { page }

    it { should have_text ('Welcome, Matt!') }
    it { should have_text ('You have 0 Plink Points.') }
    it { should have_link ('Dashboard') }
    it { should have_link ('Wallet') }
    it { should have_link ('Rewards') }
    it { should have_link ('My Account') }
    it { should have_link ('Log Out') }
  end
end

def login_new_user
  create_virtual_currency(name: 'Plink Points', subdomain: 'www')
  create_user(email: 'nav_test@example.com', password: 'test123', first_name: 'Matt')
  

  visit '/'
  click_on "Sign In"
  fill_in 'Email', with: 'nav_test@example.com'
  fill_in 'Password', with: 'test123'
  click_on 'Log in'
end
