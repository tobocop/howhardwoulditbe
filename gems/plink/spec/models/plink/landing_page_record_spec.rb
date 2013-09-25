require 'spec_helper'

describe Plink::LandingPageRecord do
  let(:valid_params) {
    {
      name: 'The best page in the universe',
      partial_path: '/_hereitis.html.haml'
    }
  }

  subject { Plink::LandingPageRecord.new(valid_params) }

  it { should have_many(:registration_link_landing_page_records) }
  it { should have_many(:registration_link_records).through(:registration_link_landing_page_records) }

  it 'can be persisted' do
    Plink::LandingPageRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    let(:landing_page) { Plink::LandingPageRecord.new }

    it 'is invalid without a partial_path' do
      landing_page.should_not be_valid
      landing_page.should have(1).error_on(:partial_path)
    end

    it 'is invalid without a name' do
      landing_page.should_not be_valid
      landing_page.should have(1).error_on(:name)
    end
  end
end
