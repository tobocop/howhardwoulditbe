require 'spec_helper'

describe 'home' do
  it 'can be visited' do
    visit '/'

    page.should have_content 'Analytics Central!'
  end
end
