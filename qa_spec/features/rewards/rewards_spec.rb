require 'qa_spec_helper'

describe 'Rewards page', js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
    sign_in('qa_spec_test@example.com', 'test123')
    visit '/rewards'
  end
  subject { page }

  it {should have_text('Redeem Plink Points for these rewards') }

  it 'should show a list of all available rewards' do
  end

  it 'should show all denominations that a user can qualify for' do
  end

  describe 'when a user attempts to redeem', js: true do
    #need to assign points to a user

    it 'should decrement a users point total when they redeem' do
    end

    it 'should reject a user who does not have a card added' do
      click_on '$5.00'
      #href - "/redemptions?reward_amount_id=1"
      page.should have_text('You must have a linked card to redeem an award.')
    end

    it 'should reject a user who does not have enough points to redeem' do
    end
  end

end