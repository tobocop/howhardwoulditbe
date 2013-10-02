require 'spec_helper'

describe Plink::UsersAwardPeriodRecord do
  it { should allow_mass_assignment_of(:advertisers_rev_share) }
  it { should allow_mass_assignment_of(:begin_date) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:offers_virtual_currency_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      advertisers_rev_share: 0.5,
      begin_date: Time.zone.today,
      offers_virtual_currency_id: 3,
      user_id: 1
    }
  }

  subject { Plink::UsersAwardPeriodRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'is valid' do
    subject.save!
  end

  it 'defaults end_date to 100 years from now' do
    subject.end_date.should == 100.years.from_now.at_midnight
  end
end
