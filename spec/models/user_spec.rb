require 'spec_helper'

describe User do
  subject { new_user }

  it "be valid" do
    subject.should be_valid
  end

  it "must have a first name" do
    subject.first_name = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:first_name)
  end

  it "must have an email address" do
    subject.email = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:email)
  end

  it "must have a password hash" do
    subject.password_hash = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:password_hash)
  end

  it "must have a salt" do
    subject.salt = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:salt)
  end

  it "does not allow emails to be duplicates" do
    other_user = new_user
    other_user.email = subject.email
    other_user.save!

    subject.should_not be_valid
    subject.should have(1).error_on(:email)
  end

  it_should_behave_like(:legacy_timestamps)

  it "has a primary virtual currency" do
    subject.primary_virtual_currency = create_virtual_currency
    subject.save!

    subject.primary_virtual_currency.should be
  end

  it "sets the virtual currency to the default Plink Points currency" do
    plink_point_currency = create_virtual_currency
    VirtualCurrency.stub(:default) { plink_point_currency }
    subject.save!

    subject.primary_virtual_currency.should == plink_point_currency
  end

  describe "class methods" do
    it "finds a user by their email address" do
      user = create_user
      User.find_by_email(user.email).should == user
    end
  end
end