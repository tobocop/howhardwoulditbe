require 'qa_spec_helper'

describe 'Rewards page', js: true do
  pending 'update' do

    let(:user) { create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA') }

    before(:each) do
      virtual_currency = create_virtual_currency(name: 'Plink Points', subdomain: 'www')

      award_points_to_user(user_id: user.id, dollar_award_amount: 6, currency_award_amount: 600, virtual_currency_id: virtual_currency.id)

      create_reward(name: 'Walmart Gift Card', amounts:
          [
              new_reward_amount(dollar_award_amount: 5, is_active: true),
              new_reward_amount(dollar_award_amount: 10, is_active: true)
          ]
      )

      sign_in('qa_spec_test@example.com', 'test123')
      visit '/rewards'
    end

    subject { page }

    it { should have_text('CHOOSE YOUR REWARD') }

    it 'should show a list of all available rewards' do
      page.should have_text('Walmart Gift Card')
      page.should have_text('$5')
    end

    it 'should show all denominations that a user can qualify for' do
      sleep 5
      page.should have_link('$5')
      page.should have_text('$10')
    end

    it 'should not present awards to a user who cannot afford it' do
        page.should_not have_link('$10')
    end

    context 'when the user has linked card' do
      before(:each) do
        link_card_for_user(user.id)
      end

      it 'should decrement a users point total when they redeem', js: true do
        within '.header' do
          page.should have_text('You have 600 Plink Points.')
        end

        click_on '$5'

        within '.header' do
          page.should have_text('You have 100 Plink Points.')
        end
      end
    end

    context 'when the user does not have a linked card' do
      it 'should reject a user who does not have a card added', js: true do
        click_on '$5'
        page.should have_text('You must have a linked card to redeem an award.')
      end
    end
  end
end