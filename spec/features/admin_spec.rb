require 'spec_helper'

describe 'Admins' do
  it 'can get to a sign in form' do
    visit '/plink_admin'

    page.should have_content 'Sign in'
  end

  it 'lets an admin sign in as another user', :vcr do

    create_app_user(email: 'jumbalaya@example.com')

    create_admin(email: 'admin@example.com', password: 'pazzword')

    sign_in_admin('admin@example.com', 'pazzword')

    click_on 'Find Users'

    fill_in 'email', with: 'jumbalaya@example.com'
    click_on 'Search'

    within '.search-results' do
      within 'tr', text: 'jumbalaya@example.com' do
        click_on "Impersonate"
      end
    end

    page.current_path.should == wallet_path
    page.should have_content 'Welcome, '

    click_on "Stop impersonating"

    page.current_path.should == plink_admin.root_path

    visit root_path

    page.should_not have_link 'Stop impersonating'
  end
end
