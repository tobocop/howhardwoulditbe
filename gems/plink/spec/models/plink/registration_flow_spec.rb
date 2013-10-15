require 'spec_helper'

describe Plink::RegistrationFlow do
  let(:landing_page_one) { create_landing_page(name: 'one') }
  let(:landing_page_two) { create_landing_page(name: 'two', partial_path: 'myawesome.path.haml') }

  let(:share_page_one) { create_share_page(name: 'one') }
  let(:share_page_two) { create_share_page(name: 'two', partial_path: 'myawesome.path.haml') }

  let(:registration_link) {
    create_registration_link(
      affiliate_id: 3,
      campaign_id: 4,
      landing_page_records: [landing_page_one, landing_page_two],
      mobile_detection_on: true
    )
  }

  describe '#initialize' do
    it 'returns a randomly chosen landing_page' do
      Array.any_instance.should_receive(:sample).and_return(landing_page_two)

      registration_flow = Plink::RegistrationFlow.new(registration_link)
      registration_flow.landing_page_partial.should == 'myawesome.path.haml'
      registration_flow.landing_page_id.should == landing_page_two.id
      registration_flow.affiliate_id.should == 3
      registration_flow.campaign_id.should == 4
    end

    it 'returns a randomly chosen share_page' do
      registration_link.share_page_records << share_page_one
      registration_link.share_page_records << share_page_two

      registration_flow = Plink::RegistrationFlow.new(registration_link)

      [share_page_one.id, share_page_two.id].should include registration_flow.share_page_id
    end
  end

  describe '#live?' do
    it 'calls the registration link record' do
      registration_link.should_receive(:live?).and_return(true)
      registration_path = Plink::RegistrationFlow.new(registration_link)
      registration_path.live?.should be_true
    end
  end

  describe '#mobile_detection_on?' do
    let(:non_mobile_registration_link) {
      create_registration_link(
        affiliate_id: 3,
        campaign_id: 4,
        landing_page_records: [landing_page_one, landing_page_two],
        mobile_detection_on: false
      )
    }

    it 'returns true if the record is flagged to have mobile detection' do
      registration_path = Plink::RegistrationFlow.new(registration_link)
      registration_path.mobile_detection_on?.should be_true
    end

    it 'returns false if the record is not flagged to have mobile detection' do
      registration_path = Plink::RegistrationFlow.new(non_mobile_registration_link)
      registration_path.mobile_detection_on?.should be_false
    end
  end
end
