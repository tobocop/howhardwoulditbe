require 'spec_helper'

describe SubscriptionsController do
  let(:mock_plink_user_service) { mock(:plink_user_service) }

  before do
    set_current_user(id: 3)
    set_virtual_currency
    controller.stub(plink_user_service: mock_plink_user_service)
  end

  describe 'PUT update' do
    it 'updates the users email preferences with the given value' do
      mock_plink_user_service.should_receive(:update_subscription_preferences).with(3, is_subscribed: '0')

      xhr :put, :update, is_subscribed: '0'

      JSON.parse(response.body).should == {}
    end
  end
end