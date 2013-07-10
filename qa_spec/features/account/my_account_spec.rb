require 'qa_spec_helper'

describe 'My Account page', js: true do 
  before(:each) do
    virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")
    @user = Plink::User.where(emailAddress: "email@Plink.com").first
    award_points_to_user(user_id: @user.id, dollar_award_amount: 6, currency_award_amount: 600, virtual_currency_id: virtual_currency.id)
  end

  it 'should be accessible to plink members' do
    click_on 'My Account'
    current_path.should == '/account'
  end

  it 'should be accessible to linked plink members' do
    link_card_for_user(@user.userID)
    click_on 'My Account'
    current_path.should == '/account'
  end

  it 'should present the user with a link to add/change a card' do
    click_on 'My Account'
    page.should have_link 'Link Card'
  end

  it 'should display the users current and lifetime point balance' do
    click_on 'My Account'
    page.should have_text "You have 600 Plink Points."
    page.should have_text "Lifetime balance: 600 Plink Points"
  end

  it 'should display the users status and email' do
    click_on 'My Account'
    page.should have_text 'Card Linked?: false'
    page.should have_text "Email: #{@user.emailAddress}"
  end

  it 'should allow the user to manage their social profiles' do
  end

  it 'should link to the contact form' do
    visit '/account'
    page.should have_link 'Contact Us'
  end
end