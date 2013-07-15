require 'spec_helper'

describe 'Authentication' do
  it 'allows a user to log in' do
    create_admin(email: 'admin@example.com', password: 'pazzword')

    visit '/'

    page.should have_content 'Sign in'

    fill_in 'Email', with: 'admin@example.com'
    fill_in 'Password', with: 'pazzword'

    click_on 'Sign in'

    page.should have_content 'Welcome!'
  end

  it 'does now allow a user to sign in with an incorrect password' do
    visit '/'

    page.should have_content 'Sign in'

    fill_in 'Email', with: 'admin@example.com'
    fill_in 'Password', with: 'pazzword'

    click_on 'Sign in'

    page.should have_content 'Invalid email or password.'
    page.current_path.should == '/admins/sign_in'
  end
end
