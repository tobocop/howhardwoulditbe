require 'spec_helper'

describe User do
  subject { new_user }

  it "be valid" do
    subject.should be_valid
  end

  it "must have an email address" do
    subject.email = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:email)
  end

  it_should_behave_like(:legacy_timestamps)

  it "has a primary virtual currency" do
    subject.primary_virtual_currency = create_virtual_currency
    subject.save!

    subject.primary_virtual_currency.should be
  end

  pending "sets the virtual currency to the default Plink Points currency" do
    plink_point_currency = stub
    subject.save!

    subject.primary_virtual_currency.should == plink_point_currency
  end


end