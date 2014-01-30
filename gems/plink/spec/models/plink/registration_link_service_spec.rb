require 'spec_helper'

describe Plink::RegistrationLinkService do
  subject(:registration_link_service) { Plink::RegistrationLinkService }

  describe '.get_registration_flow_by_registration_link_id' do
    let(:registration_link_record) { double(Plink::RegistrationLinkRecord) }
    let(:registration_flow) { double(Plink::RegistrationFlow) }

    before do
      Plink::RegistrationLinkRecord.stub(:find).and_return(registration_link_record)
      Plink::RegistrationFlow.stub(:new).and_return(registration_flow)
    end

    it 'looks up the registration link record by id' do
      Plink::RegistrationLinkRecord.should_receive(:find).with(34).and_return(registration_link_record)

      registration_link_service.get_registration_flow_by_registration_link_id(34)
    end

    it 'returns a registration flow object' do
      Plink::RegistrationFlow.should_receive(:new).with(registration_link_record).and_return(registration_flow)

      registration_flow = registration_link_service.get_registration_flow_by_registration_link_id(34)
      registration_flow.should == registration_flow
    end
  end
end
