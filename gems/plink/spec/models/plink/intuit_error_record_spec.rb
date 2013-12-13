require 'spec_helper'

describe Plink::IntuitErrorRecord do
  require 'spec_helper'

  it { should allow_mass_assignment_of(:error_description) }
  it { should allow_mass_assignment_of(:error_prefix) }
  it { should allow_mass_assignment_of(:intuit_error_id) }
  it { should allow_mass_assignment_of(:send_reverification) }
  it { should allow_mass_assignment_of(:user_message) }

  it { should validate_presence_of(:error_description) }

  let(:valid_params) do
    {
      error_description: 'not nil',
      error_prefix: 'also not nil',
      user_message: nil
    }
  end

  it 'can be persisted' do
    Plink::IntuitErrorRecord.create(valid_params).should be_persisted
  end
end
