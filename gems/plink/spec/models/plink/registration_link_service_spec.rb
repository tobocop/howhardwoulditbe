require 'spec_helper'

describe Plink::RegistrationLinkService do
  describe '.get_registration_path_by_registration_link_id' do
    let(:landing_page) { create_landing_page(partial_path: 'mypath.html.haml') }

    let!(:registration_link) {
      create_registration_link(
        landing_page_records: [landing_page]
      )
    }
    

    it 'returns a RegistrationPath record by registration_link_id' do
      registration_path = Plink::RegistrationLinkService.get_registration_path_by_registration_link_id(registration_link.id)
      registration_path.should be_a Plink::RegistrationPath
      registration_path.landing_page_partial.should == 'mypath.html.haml'
    end
  end
end
