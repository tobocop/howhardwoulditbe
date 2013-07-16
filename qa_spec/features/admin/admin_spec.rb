require 'qa_spec_helper'

describe 'Admin portal', js: true do

  it 'should only be available to Plink administrators' do
  	visit '/plink_admin'
    fill_in 'Email', with: 'pivotal@plink.com'
    fill_in 'Password', with: 'password'
    page.should have_text 'Welcome!'
  end

  it 'should not be available to non-admins' do
  	visit '/plink_admin'
    fill_in 'Email', with: 'bullshit@fake.com'
    fill_in 'Password', with: 'test123'
    page.should have_text 'Invalid email or password.'
    current_path.should =='plink_admin/admins/sign_in'
  end

  context 'as a Plink administrator' do
    before(:each) do
      #sign in user (admin)
    end
    
  end
end