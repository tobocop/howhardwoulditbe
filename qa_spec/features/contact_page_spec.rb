require 'qa_spec_helper'

describe "Contact Page" do 
  it "has a title" do
    visit "/contact.html"
    page.should have_content "Contact us..."
  end
end