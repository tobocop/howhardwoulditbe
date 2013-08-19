require 'spec_helper'

describe RedemptionHelper do
  describe '#redemption_message' do
    context 'for a user with less than 500 points' do
      it 'returns a message indicating how many points they have until 500 points' do
        helper.redemption_message(321, 'currency name').should == "You're <strong>179 currency name</strong> from your next reward."
      end
    end
    context 'for a user with less than 1000 points' do
      it 'returns a message indicating how many points they have until 1,000 points' do
        helper.redemption_message(721, 'currency name').should == "You're <strong>279 currency name</strong> from your next reward."
      end
    end
    context 'for a user with >= 1000 points' do
      it 'returns a message indicating that they can redeem' do
        helper.should_receive(:link_to).with("You have enough currency name to redeem for a Gift card.", '/rewards', {class: 'redeem-link'}).and_return("You have enough currency name to redeem for a Gift card.")
        helper.redemption_message(1001, 'currency name').should == "You have enough currency name to redeem for a Gift card."
      end
    end
  end
end
