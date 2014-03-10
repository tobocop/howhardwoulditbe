require 'spec_helper'

describe Plink::AwardLinkClickRecord do
  it { should allow_mass_assignment_of(:award_link_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      award_link_id: 2,
      user_id: 4
    }
  }

  it 'can be persisted' do
    Plink::AwardLinkClickRecord.create(valid_params).should be_persisted
  end
end
