require 'spec_helper'

describe IntuitInstitutionRequest do
  describe '.institution_data' do
    it 'calls intuit for data about a specific institution' do
      aggcat = double(Aggcat)
      Aggcat.stub(:scope).and_return(aggcat)

      aggcat.should_receive(:institution).with(10000)

      IntuitInstitutionRequest.institution_data(1, 10000)
    end
  end
end
