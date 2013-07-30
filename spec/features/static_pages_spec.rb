require 'spec_helper'

describe 'Static pages' do
  it 'can be reached from the footer' do
    visit '/'

    within '.footer' do
      click_on 'FAQ'
    end

    page.should have_content 'FAQ'

    within '.footer' do
      click_on 'Terms of Service'
    end

    page.should have_content 'Service Terms'

  end
end