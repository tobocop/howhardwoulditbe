require 'spec_helper'

describe Plink::IntuitAccountService do

  describe 'user_has_account?' do
    it 'returns true if the user has an active intuit account' do
      Plink::ActiveIntuitAccountRecord.should_receive(:user_has_account?).with(4).and_return(true)

      subject.user_has_account?(4).should == true
    end

    it 'returns false if the user does not have an active intuit account' do
      Plink::ActiveIntuitAccountRecord.should_receive(:user_has_account?).with(5).and_return(false)

      subject.user_has_account?(5).should == false
    end
  end
end
