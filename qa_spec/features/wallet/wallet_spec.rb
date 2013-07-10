require 'qa_spec_helper'

describe "Wallet page", js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")
    visit '/wallet'
  end

  subject { page }

  it { should have_text ('My Wallet') }

  context 'upon a users first visit' do
    it 'should have three open slots initially' do
      page.should have_css('h3', text: 'This slot is empty', count: 3)
    end

    it 'should have one locked slot before an offer is completed' do
      page.should have_css('h3', text: 'This slot is locked.')
      page.should have_css('h3', text: 'Complete an offer to unlock this slot.')
    end

    it 'should have one locked slot before a friend is referred' do
      pending 'Awaiting Implementation' do
        page.should have_css('h3', text: 'This slot is locked.')
        page.should have_css('h3', text: 'Refer a friend to unlock this slot.')
      end
    end
  end

  context 'before a user has linked a card' do
    it 'should prompt the user to link a card on the offer details modal' do
    end

    it 'should not allow the user to add an offer to the wallet' do
    end
  end

  context 'after a user has linked a card' do
    it 'should allow the user to add an offer to the wallet' do
    end

    it 'should not allow duplicate offers in the wallet' do
    end

    it 'should allow a user to remove an offer from the wallet' do
    end
  end
end