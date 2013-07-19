require 'qa_spec_helper'

describe 'Admin portal', js: true do

  it 'should only be available to Plink administrators' do
    create_admin

  	visit '/plink_admin'
    fill_in 'Email', with: 'my_admin@example.com'
    fill_in 'Password', with: 'password'
    click_on 'Sign in'
    page.should have_text 'Signed in successfully.'
    page.should have_text 'Welcome!'
  end

  it 'should not be available to non-admins' do
  	visit '/plink_admin'
    fill_in 'Email', with: 'bullshit@fake.com'
    fill_in 'Password', with: 'test123'
    click_on 'Sign in'
    page.should have_text 'Invalid email or password.'
    current_path.should =='/plink_admin/admins/sign_in'
  end

  context 'as a Plink administrator' do
    before(:each) do
      sign_in_admin 
    end
    
    it 'should work' do
      page.should have_text 'Welcome!'
    end

  end
end


