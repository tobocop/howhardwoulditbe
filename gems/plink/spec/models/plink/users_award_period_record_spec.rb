require 'spec_helper'

describe Plink::UsersAwardPeriodRecord do
  let(:valid_params) { { user_id: 1, begin_date: Date.today, advertisers_rev_share: 0.5, offers_virtual_currency_id: 3 } }
  subject { Plink::UsersAwardPeriodRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'is valid' do
    subject.save!
  end

  it 'defaults end_date to 100 years from now' do
    subject.end_date.should == 100.years.from_now.at_midnight
  end
end