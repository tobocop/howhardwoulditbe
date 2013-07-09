require 'qa_spec_helper'

describe 'Lefthand nav bar', js: true do
    before(:each) do
      create_virtual_currency(name: 'Plink Points', subdomain: 'www')
      create_user(email: 'qa_spec_test@example.com', password: 'test123', first_name: 'QA')
      sign_in('qa_spec_test@example.com', 'test123')
    end

    subject { page }

    it { should have_text ('QA') }
    it { should have_text ('Level 5000') }      #Will change; currently hard coded
    it { should have_text ('9,999,999 EBs') }
    it { should have_link ('Invite Friends') }

  it 'should show a blank silhouette before linking to a social network' do
    page.should have_image "silhouette"
  end
end

