require 'qa_spec_helper'

describe 'My Account page', js: true do 
  before(:each) do
    @virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www', exchange_rate: 100)
    sign_up_user(first_name: "tester", email: "email@Plink.com", password: "test123")
    @user = Plink::User.where(emailAddress: "email@Plink.com").first
    award_points_to_user(user_id: @user.id, dollar_award_amount: 6, currency_award_amount: 600, virtual_currency_id: @virtual_currency.id)
  end

  it 'should be accessible to plink members' do
    click_on 'My Account'
    current_path.should == '/account'
  end  

  it 'should present the user with a link to add/change a card' do
    click_on 'My Account'
    click_on 'Link Card'
    page.should have_css '#card-add-modal'
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

  it 'should link to the contact form' do
    visit '/account'
    page.should have_link 'Contact Us'
  end


  context 'when a user has added a card' do
    before(:each) do
      link_card_for_user(@user.userID)
    end

    it 'should display the bank and account that the user has linked' do
      pending 'Awaiting Implementation' do
        page.should have_text 'Card Linked?: true'
        page.should have_text 'CC Bank'
        page.should have_text ''#Account Name here
      end
    end

    it 'should be accessible to linked plink members' do
      link_card_for_user(@user.userID)
      click_on 'My Account'
      current_path.should == '/account'
    end

    it 'should display a users recent activity' do
      click_on 'My Account'
      page.should have_text 'RECENT ACTIVITY'
      page.should have_text 'DATE'
      page.should have_text 'DESCRIPTION'
      page.should have_text 'AMOUNT'
    end      

    it 'should display an award when a user is awarded points' do
      award_points_to_user(user_id: @user.id, dollar_award_amount: 1, currency_award_amount: 1000, virtual_currency_id: @virtual_currency.id)
      click_on 'My Account'
      page.should have_text('1000 Plink Points')
      page.should have_image "icon_bonus"
    end

    it 'should display an redemption activity when a user redeems' do
      create_reward(name: 'Amazon Gift Card', amounts: [ new_reward_amount(dollar_award_amount: 5, is_active: true) ] )
      click_on 'Rewards'
      click_on('$5.00', match: :first)
      click_on 'My Account'
      page.should have_text('$5 Amazon Gift Card')
      page.should have_text('-500 Plink Points')
      page.should have_image('icon_redeem')
    end

    it 'should display no more than 20 activities at a time' do
      21.times { award_points_to_user(user_id: @user.id, dollar_award_amount: 6, currency_award_amount: 600, virtual_currency_id: @virtual_currency.id) }
      click_on 'My Account'
      page.should have_text('600 Plink Points', count: 20)
    end
  end
end