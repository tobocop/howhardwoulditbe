require 'qa_spec_helper'

describe "Wallet page", js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')

    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")

    visit '/wallet'
  end

  subject { page }

  it { pending; should have_text ('My Wallet') }

  it 'should have three open slots initially' do
    pending 'Waiting for implementation' do
      page.should have_css('h3', text: 'This slot is empty', count: 3)
    end
  end
end

