require 'spec_helper'

describe RedemptionHelper do
  describe '#redemption_message' do
    it 'returns a message telling a user how many points until the next redemption if the given value is a positive number' do
      helper.redemption_message(400, 'currency name').should == "You're <strong>400 currency name</strong> from your next reward."
    end

    it 'returns a link to the redemption page if the points until next redemptions is negative (they have enough)' do
      helper.should_receive(:link_to).with("You have enough Plink Points to redeem for a Gift card.", '/rewards', anything).and_return('You have enough Plink Points to redeem for a Gift card.')
      helper.redemption_message(-300, 'currency name').should == "You have enough Plink Points to redeem for a Gift card."
    end
  end
end
