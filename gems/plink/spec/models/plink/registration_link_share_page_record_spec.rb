require 'spec_helper'

describe Plink::RegistrationLinkSharePageRecord do
  let(:valid_params) {
    {
      registration_link_id: 1,
      share_page_id: 2
    }
  }

  it { should belong_to(:registration_link_record) }
  it { should belong_to(:share_page_record) }

  it 'can be persisted' do
    Plink::RegistrationLinkSharePageRecord.create(valid_params).should be_persisted
  end
end
