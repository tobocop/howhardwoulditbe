require 'qa_spec_helper'

describe 'Logged out Home page', js: true do
  before(:each) do
    create_virtual_currency(name: 'Plink Points', subdomain: 'www')
    visit '/'
  end

  subject {page}

  it {should have_text('view offers') }

  it 'should allow a guest to view all offers' do
    click_on 'view offers'
    page.should have_text('Earn Plink Points at these locations.')
  end

  it 'should allow a guest to view all rewards' do
    click_on 'view rewards'
    page.should have_text('CHOOSE YOUR REWARD.')
  end

  it 'should allow a guest to send an email via the Contact Us form' do
    click_on 'Contact Us'
    page.should have_text('Contact Us')
  end

  it 'should allow the user to like Plink on Facebook' do
    pending 'awaiting deployment' do
      page.should have_css '[gigid="showShareBarUI"]'
      within_frame 'fa7421a30fdeaa' do 
        click_on 'submit'
      end
      # Do FB Stuff...within moda,, page should ahve text facebook
    end
  end
end