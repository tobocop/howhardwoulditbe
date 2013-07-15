require 'spec_helper'

describe 'Admins' do
  it 'can get to a sign in form' do
    visit '/plink_admin'

    page.should have_content 'Sign in'
  end
end
