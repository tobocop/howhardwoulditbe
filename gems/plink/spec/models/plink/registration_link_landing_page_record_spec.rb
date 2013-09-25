require 'spec_helper'

describe Plink::RegistrationLinkLandingPageRecord do
  let(:valid_params) {
    {
      registration_link_id: 1,
      landing_page_id: 2
    }
  }

  it { should belong_to(:registration_link_record) }
  it { should belong_to(:landing_page_record) }

  it 'can be persisted' do
    Plink::RegistrationLinkLandingPageRecord.create(valid_params).should be_persisted
  end
end
