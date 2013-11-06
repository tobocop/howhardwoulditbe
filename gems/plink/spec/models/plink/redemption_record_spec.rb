require 'spec_helper'

describe Plink::RedemptionRecord do

  it { should allow_mass_assignment_of(:dollar_award_amount) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:is_pending) }
  it { should allow_mass_assignment_of(:reward_id) }
  it { should allow_mass_assignment_of(:sent_on) }
  it { should allow_mass_assignment_of(:tango_confirmed) }
  it { should allow_mass_assignment_of(:tango_tracking_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      dollar_award_amount: 2.3,
      reward_id: 2,
      user_id: 1,
      is_pending: true,
      is_active: true,
      sent_on: nil,
      tango_confirmed: false
    }
  }

  subject { Plink::RedemptionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'should be persisted' do
    redemption = Plink::RedemptionRecord.create(valid_params)
    redemption.should be_persisted
    redemption.is_pending.should be_true
  end

end

