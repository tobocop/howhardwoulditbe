require 'spec_helper'

describe Plink::RegistrationPath do
  let(:landing_page_one) { create_landing_page(name: 'one') }
  let(:landing_page_two) { create_landing_page(name: 'two', partial_path: 'myawesome.path.haml') }
  let(:registration_link) {
    create_registration_link(
      affiliate_id: 3,
      campaign_id: 4,
      landing_page_records: [landing_page_one, landing_page_two]
    )
  }

  it 'sets landing_page to be a random page from the landing_pages_array' do
    Array.any_instance.should_receive(:sample).and_return(landing_page_two)

    registration_path = Plink::RegistrationPath.new(registration_link)
    registration_path.landing_page_partial.should == 'myawesome.path.haml'
    registration_path.landing_page_id.should == landing_page_two.id
    registration_path.affiliate_id.should == 3
    registration_path.campaign_id.should == 4
  end

  describe '.live?' do
    it 'calls the registration link record' do
      registration_link.should_receive(:live?).and_return(true)
      registration_path = Plink::RegistrationPath.new(registration_link)
      registration_path.live?.should be_true
    end
  end
end
