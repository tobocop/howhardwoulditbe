require 'spec_helper'

describe 'User Management' do
  before do
    create_admin(email: 'admin@example.com', password: 'pazzword')
    @user = create_user(first_name: 'oldmanjumbo', email: 'jumbalaya@example.com')
  end

  it 'lets an admin find users by email' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_on 'Find Users'

    fill_in 'email', with: 'jumbalaya@example.com'
    click_on 'Search'

    within '.search-results' do
      page.should have_content 'oldmanjumbo'
    end
  end

  it 'lets an admin sign in as another user' do
    sign_in_admin(email: 'admin@example.com', password: 'pazzword')

    click_on 'Find Users'

    fill_in 'email', with: 'jumbalaya@example.com'
    click_on 'Search'

    within '.search-results' do
      within 'tr', text: 'jumbalaya@example.com' do
        click_on "Impersonate"
      end
    end

    page.current_path.should == PlinkAdmin.impersonation_redirect_url
  end
end
