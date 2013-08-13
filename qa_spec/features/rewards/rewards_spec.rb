require 'qa_spec_helper'

describe 'Rewards page', js: true do

  let(:user) {
    create_user(email: 'test@plink.com', password: 'test123', first_name: 'QA') }

  before(:each) do
    @virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    wallet = create_wallet(user_id: user.id)

    @reward = create_reward(name: 'Amazon Gift Card', description: 'amazon.com', terms: '<a href="#">amazon TOC</a>',
      amounts:
        [ new_reward_amount(dollar_award_amount: 5, is_active: true),
          new_reward_amount(dollar_award_amount: 10, is_active: true),
          new_reward_amount(dollar_award_amount: 15, is_active: true),
          new_reward_amount(dollar_award_amount: 20, is_active: true)
        ] )
  end

  subject { page }

  context 'as a non-linked user' do
    before(:each) do
      sign_in('test@plink.com', 'test123')
      click_on 'Rewards'
    end

    it { should have_text "CHOOSE YOUR REWARD"}
    it { should have_text "Why can't I redeem for more than $10?"}
    it { should_not have_text 'iTunes&reg;'}

    it 'should see the reward information' do
      page.should have_image 'amazon'
      page.should have_text 'Amazon Gift Card'
      page.should have_text '$5'
      page.should have_text '$10'
      page.should have_text '$15'
    end

    it 'should see all the reward amounts, but not allow the user to redeem' do
      page.should_not have_link '$5'
      page.should_not have_link '$10'
      page.should have_css('div', 'denomination unavailable')
    end

    it 'should see all rewards greater than $10 as locked' do
      page.should have_image('icon_lock', count: 2)
    end
  end


  context 'as a linked user with enough points to redeem' do
    before(:each) do
      create_oauth_token(user_id: user.id)
      users_virtual_currency = create_users_virtual_currency(user_id: user.id, virtual_currency_id: @virtual_currency.id)
      institution = create_institution(name: 'Bankhead')
      users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
      create_users_institution_account(
        user_id: user.id,
        name: 'checks on checks on checks',
        users_institution_id: users_institution.id,
        account_number_last_four: 4321
      )

      award_points_to_user(
          user_id: user.id,
          dollar_award_amount: 10.43,
          currency_award_amount: 1043,
          virtual_currency_id: @virtual_currency.id
      )

      sign_in('test@plink.com', 'test123')
    end

    it 'should be able to redeem for a reward they can afford' do
      click_on 'Rewards'
      redeem_for_reward_and_dollar_amount(@reward, 5)
      validate_reward_on_account(@reward, user, 5)
    end

    it 'should not be able to click confirm more than once, limiting redemptions' do
      click_on 'Rewards'
      page.find('a', text: "$5").click
      within '.modal' do
        click_on 'CONFIRM'
      end
      page.should_not have_link 'CONFIRM'
    end

    it 'cannot redeem directly via the url' do
      click_on 'Rewards'
      visit '/redemption?reward_amount_id=1'
      click_on 'My Account'
      page.should_not have_text '-500 Plink Points'
      page.should_not have_image('icon_redeem')
    end
  end
end
