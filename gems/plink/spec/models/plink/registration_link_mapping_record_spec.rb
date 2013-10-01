require 'spec_helper'

describe Plink::RegistrationLinkMappingRecord do
  let(:valid_params) {
    {
      affiliate_id: 3,
      campaign_id: 4,
      registration_link_id: 1
    }
  }

  it { should belong_to(:registration_link_record) }

  it 'can be persisted' do
    Plink::RegistrationLinkMappingRecord.create(valid_params).should be_persisted
  end
end

