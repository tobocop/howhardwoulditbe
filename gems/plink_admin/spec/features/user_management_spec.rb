require 'spec_helper'

describe 'User Management' do
  let!(:virtual_currency) { create_virtual_currency }
  let!(:user) { create_user(first_name: 'oldmanjumbo', email: 'jumbalaya@example.com') }
  let!(:fishy_user) { create_user(first_name: 'sea bass', email: 'redsnapper@redlobster.melvin') }
  let!(:wallet) { create_wallet(user_id: user.id) }
  let!(:open_wallet_item) { create_open_wallet_item(wallet_id: wallet.id) }
  let!(:locked_wallet_item) { create_locked_wallet_item(wallet_id: wallet.id) }
  let!(:populated_wallet_item) { create_populated_wallet_item(wallet_id: wallet.id) }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    institution = create_institution(name: 'Bank of representin')
    users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
    create_users_institution_account(user_id: user.id, name: 'representing checks', users_institution_id: users_institution.id, account_number_last_four: nil)
    create_intuit_fishy_transaction(user_id: user.id, other_fishy_user_id: fishy_user.id)

    create_reward(
      name: 'Tango Card', award_code: 'tango-card', description: '<a href="#">it takes two</a>', is_tango: true, terms: '<a href="#">Tango card terms</a>',
      amounts:
        [
          new_reward_amount(dollar_award_amount: 5, is_active: true),
          new_reward_amount(dollar_award_amount: 10, is_active: true),
          new_reward_amount(dollar_award_amount: 15, is_active: false)
        ]
    )
  end

  it 'lets an admin manage users' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_on 'Find Users'

    fill_in 'email', with: 'jumbalaya@example.com'
    click_on 'Search'

    within '.search-results' do
      page.should have_content 'oldmanjumbo'
      click_on 'Edit User'
    end

    page.should have_link 'Impersonate User'
    page.should have_content 'Locked Wallet Items: 1'
    page.should have_content 'Open Wallet Items: 1'
    page.should have_content 'Populated Wallet Items: 1'
    page.should have_content 'Bank of representin'
    page.should have_content 'representing checks'

    within '.fishy-status' do
      page.should have_content 'Fishy Status - Fishy'
      page.should have_content user.id
      page.should have_content fishy_user.id
      page.should have_link '( New Admin )'
      page.should have_link '( Old Admin )'
    end

    page.should have_content 'Send Reward'
    select 'Tango Card - $10.0', from: 'reward_amount_id'
    click_on 'Reward User'

    page.should have_content 'User does not have enough points'

    advertiser = create_advertiser
    create_qualifying_award(
      currency_award_amount: 1000,
      dollar_award_amount: 10,
      user_id: user.id,
      virtual_currency_id: virtual_currency.id,
      advertiser_id: advertiser.id
    )

    select 'Tango Card - $10', from: 'reward_amount_id'
    click_on 'Reward User'
    page.should have_content 'Redemption pending'

    fill_in 'user_email', with: 'gumbo@example.com'
    check 'user_hold_redemptions'
    click_on 'Save'

    page.should have_content 'User successfully updated'
    find_field('user_email').value.should == 'gumbo@example.com'
    find_field('user_hold_redemptions').should be_checked

    check 'user_is_force_deactivated'
    click_on 'Save'

    page.should have_content 'User successfully updated'
    find_field('user_is_force_deactivated').should be_checked

    click_on 'Find Users'
    fill_in 'email', with: 'resetByAdmin_gumbo@example.com'
    click_on 'Search'

    within '.search-results' do
      page.should have_content 'gumbo'
      click_on 'Edit User'
    end

    uncheck 'user_is_force_deactivated'
    click_on 'Save'

    page.should have_content 'User successfully updated'

    click_on 'Find Users'

    fill_in 'user_id', with: user.id
    click_on 'Search'

    within '.search-results' do
      page.should have_content 'oldmanjumbo'
      within 'tr', text: 'gumbo@example.com' do
        click_on "Impersonate"
      end
    end

    page.current_path.should == PlinkAdmin.impersonation_redirect_url
  end
end
