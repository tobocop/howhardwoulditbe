require 'spec_helper'

describe Plink::SharePageRecord do
  let(:valid_params) {
    {
      name: 'The best share page in the universe',
      partial_path: '/_hereitis.html.haml'
    }
  }

  subject { Plink::SharePageRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::SharePageRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    let(:share_page) { Plink::SharePageRecord.new }

    it 'is invalid without a partial_path' do
      share_page.should_not be_valid
      share_page.should have(1).error_on(:partial_path)
    end

    it 'is invalid without a name' do
      share_page.should_not be_valid
      share_page.should have(1).error_on(:name)
    end
  end
end
