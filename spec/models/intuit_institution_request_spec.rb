require 'spec_helper'

describe IntuitInstitutionRequest do
  describe '.institution_data' do
    it 'calls intuit for data about a specific institution' do
      intuit_request = double

      Intuit::Request.should_receive(:new).with(1).and_return(intuit_request)
      intuit_request.should_receive(:institution_data).with(10000)

      IntuitInstitutionRequest.institution_data(1, 10000)
    end
  end
end
