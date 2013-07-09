require 'qa_spec_helper'

describe 'Logged out Home page', js: true do
  subject {page}

  it {should have_link('view offers') }


  describe 'view all offers from homepage', js: true do

    it 'should allow a guest to view all offers' do
      visit '/'
      click_on 'view offers'
      page.should have_text('Earn Plink Points at these locations.')
      # iterate through offers and see if they are on the page
    end
  end

  describe 'view all rewards from the homepage', js: true do

    it 'should allow a guest to view all rewards' do
      visit '/'
      click_on 'view offers'
      page.should have_text('Redeem Plink Points for these rewards')
    end
  end
end