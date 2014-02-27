require 'spec_helper'

describe 'User Management' do
  let!(:user) { create_user(first_name: 'oldmanjumbo', email: 'jumbalaya@example.com') }
  let!(:wallet) { create_wallet(user_id: user.id) }
  let!(:open_wallet_item) { create_open_wallet_item(wallet_id: wallet.id) }
  let!(:locked_wallet_item) { create_locked_wallet_item(wallet_id: wallet.id) }
  let!(:populated_wallet_item) { create_populated_wallet_item(wallet_id: wallet.id) }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    institution = create_institution(name: 'Bank of representin')
    users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
    create_users_institution_account(user_id: user.id, name: 'representing checks', users_institution_id: users_institution.id, account_number_last_four: 4321)
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
    page.should have_content 'Unlock Locked Wallet Items'
    page.should have_content 'Locked Wallet Items: 1'
    page.should have_content 'Open Wallet Items: 1'
    page.should have_content 'Populated Wallet Items: 1'
    page.should have_content 'Bank of representin'
    page.should have_content 'representing checks 4321'

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
