require 'spec_helper'

describe 'Static pages' do
  it 'can be reached from the footer' do
    visit '/'

    within '.footer' do
      click_on 'FAQ'
    end

    page.should have_content 'FAQ'

  end
end
