require 'spec_helper'

describe ActiveIntuitAccount do
  describe 'self.has_account?(user_id)' do
    it 'returns false if there is no record with the given user id' do
      ActiveIntuitAccount.user_has_account?(100).should == false
    end

    it 'returns true if there is a record for the given user id' do
      ActiveIntuitAccount.should_receive(:where).with(user_id: 100) { [true] }
      ActiveIntuitAccount.user_has_account?(100).should == true
    end
  end
end
