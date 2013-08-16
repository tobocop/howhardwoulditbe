require 'spec_helper'

describe Plink::VirtualCurrency do
  let (:valid_params) {
    {
      name: 'Plink points',
      subdomain: 'domain',
      exchange_rate: 100,
      site_name: 'Plink',
      singular_name: 'Plink point',
      has_all_offers: false,
      show_tiers_as_percent: false
    }
  }
  subject { new_virtual_currency(subdomain: 'www') }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::VirtualCurrency.create(valid_params).should be_persisted
  end

  context 'validations' do
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

  context 'default_currency' do
    it 'has a default currency' do
      default_virtual_currency = double
      Plink::VirtualCurrency.should_receive(:find_by_subdomain).with('www') { default_virtual_currency }
      Plink::VirtualCurrency.default.should == default_virtual_currency
    end
  end

  describe '.find_by_subdomain' do
    before :each do
      @expected_virtual_currency = create_virtual_currency(subdomain: 'derp')
    end

    it 'can be looked up by subdomain' do
      Plink::VirtualCurrency.find_by_subdomain('derp').id.should == @expected_virtual_currency.id
    end
  end
end
