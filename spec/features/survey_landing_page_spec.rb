require 'spec_helper'

describe 'Survey landing page' do
  it 'exists' do
    visit survey_complete_url
    page.should have_content 'Thank you for your thoughts!'
  end
end
