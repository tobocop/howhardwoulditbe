require 'spec_helper'

describe Plink::ContestPrizeLevelRecord do
  let(:valid_params) {
    {
      contest_id: 1,
      award_count: 1,
      dollar_amount: 100
    }
  }

  subject { Plink::ContestPrizeLevelRecord.new(valid_params) }

  it 'can be persisted' do
    subject.save.should be_true
  end

  it { should allow_mass_assignment_of(:contest_id)}
  it { should allow_mass_assignment_of(:award_count)}
  it { should allow_mass_assignment_of(:dollar_amount)}

  it { should validate_presence_of(:award_count) }
  it { should validate_presence_of(:dollar_amount) }
end
