require 'spec_helper'

describe Plink::InstitutionRecord do
  let(:valid_params) {
    {
      hash_value: 'val',
      name: 'freds',
      intuit_institution_id: 3
    }
  }

  subject { Plink::InstitutionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    create_institution(valid_params).should be_persisted
  end

end