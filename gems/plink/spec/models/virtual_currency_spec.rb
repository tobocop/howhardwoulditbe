require 'spec_helper'

describe Plink::VirtualCurrency do
  subject { new_virtual_currency(subdomain: 'www') }

  it_should_behave_like(:legacy_timestamps)

  describe 'validations' do
    it 'it can valid' do
      subject.should be_valid
    end

    it 'should require a name' do
      subject.name = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:name)
    end

    it 'should require a singular name' do
      subject.singular_name = nil
      subject.should_not be_valid
      subject.should have(1).error_on(:singular_name)
    end

    it 'should require a subdomain' do
      subject.subdomain = nil
      subject.should_not be_nil
      subject.should have(1).error_on(:subdomain)
    end

    it 'should require an exchange rate' do
      subject.exchange_rate = nil
      subject.should_not be_nil
      subject.should have(1).error_on(:exchange_rate)
    end

    it 'should require a site name' do
      subject.site_name = nil
      subject.should_not be_nil
      subject.should have(1).error_on(:site_name)
    end

    it 'has a unique subdomain' do
      create_virtual_currency(subdomain: 'www')
      subject.should_not be_nil
      subject.should have(1).error_on(:subdomain)
    end
  end

  describe 'default_currency' do
    it 'has a default currency' do
      default_virtual_currency = stub
      Plink::VirtualCurrency.should_receive(:find_by_subdomain).with('www') { default_virtual_currency }
      Plink::VirtualCurrency.default.should == default_virtual_currency
    end
  end
end