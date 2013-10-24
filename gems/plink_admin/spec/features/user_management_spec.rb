require 'spec_helper'

describe 'User Management' do
  let!(:user) { create_user(first_name: 'oldmanjumbo', email: 'jumbalaya@example.com') }
  let!(:wallet) { create_wallet(user_id: user.id) }
  let!(:open_wallet_item) { create_open_wallet_item(wallet_id: wallet.id) }
  let!(:locked_wallet_item) { create_locked_wallet_item(wallet_id: wallet.id) }
  let!(:populated_wallet_item) { create_populated_wallet_item(wallet_id: wallet.id) }

  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
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

    page.should have_content 'Unlock Locked Wallet Items'
    page.should have_content 'Locked Wallet Items: 1'
    page.should have_content 'Open Wallet Items: 1'
    page.should have_content 'Populated Wallet Items: 1'

    click_on 'Find Users'

    fill_in 'user_id', with: user.id
    click_on 'Search'

    within '.search-results' do
      page.should have_content 'oldmanjumbo'
      within 'tr', text: 'jumbalaya@example.com' do
        click_on "Impersonate"
      end
    end

    page.current_path.should == PlinkAdmin.impersonation_redirect_url
  end
end
