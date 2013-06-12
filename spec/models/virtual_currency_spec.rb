require 'spec_helper'

describe VirtualCurrency do

  subject { new_virtual_currency }

  it "is valid" do
    subject.should be_valid
  end

  it_should_behave_like(:legacy_timestamps)

  it "should require a name" do
    subject.name = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:name)
  end

  it "should require a singular name" do
    subject.singular_name = nil
    subject.should_not be_valid
    subject.should have(1).error_on(:singular_name)
  end

  it "should require a subdomain" do
    subject.subdomain = nil
    subject.should_not be_nil
    subject.should have(1).error_on(:subdomain)
  end

  it "should require an exchange rate" do
    subject.exchange_rate = nil
    subject.should_not be_nil
    subject.should have(1).error_on(:exchange_rate)
  end

  it "should require a site name" do
    subject.site_name = nil
    subject.should_not be_nil
    subject.should have(1).error_on(:site_name)
  end

end