require 'spec_helper'

describe Plink::ActiveIntuitAccountRecord do
  describe 'self.has_account?(user_id)' do
    it 'returns false if there is no record with the given user id' do
      Plink::ActiveIntuitAccountRecord.user_has_account?(100).should == false
    end

    it 'returns true if there is a record for the given user id' do
      Plink::ActiveIntuitAccountRecord.should_receive(:where).with(user_id: 100) { [true] }
      Plink::ActiveIntuitAccountRecord.user_has_account?(100).should == true
    end
  end
end
