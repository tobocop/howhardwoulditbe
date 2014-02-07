require 'spec_helper'

describe 'logging in' do
  before do
    create_contact(email: 'awesome@partner.com', password: 'thebest', password_confirmation: 'thebest')
  end

  it 'can be logged into with an existing account' do
    visit '/'

    fill_in 'Email', with: 'awesome@partner.com'
    fill_in 'Password', with: 'the wrong'

    click_on 'Login'

    page.should have_content 'Your email or password was entered incorrectly.'

    fill_in 'Email', with: 'awesome@partner.com'
    fill_in 'Password', with: 'thebest'

    click_on 'Login'

    page.current_path.should == '/market_share'
    page.should have_content 'Welcome awesome@partner.com!'
  end
end
