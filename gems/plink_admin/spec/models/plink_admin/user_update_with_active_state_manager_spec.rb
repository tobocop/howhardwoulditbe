require 'spec_helper'

describe PlinkAdmin::UserUpdateWithActiveStateManager do
  let(:user_update_with_active_state_manager) { PlinkAdmin::UserUpdateWithActiveStateManager }
  let(:user) { new_user }
  describe '#initialize' do
    it 'raises an ArgumentError if the value passed in is not a Plink::UserRecord' do
      expect{ user_update_with_active_state_manager.new(nil) }.to raise_error ArgumentError
    end

    it 'sets the the user_record attribute to the passed in user' do
      update_manager = user_update_with_active_state_manager.new(user)

      update_manager.user_record.should == user
    end
  end

  describe '.update_attributes' do
    context 'when deactivating a user' do
      let(:active_user) {
        new_user(
          {
            id: 100,
            daily_contest_reminder: true,
            email: 'test@test.com',
            is_force_deactivated: false,
            is_subscribed: true,
            password_hash: 'HASH'
          }
        )
      }
      let(:params) { {'is_force_deactivated' => '1'} }
      let(:user_service) { double(Plink::UserService, update_subscription_preferences: true) }

      subject(:update_manager) { user_update_with_active_state_manager.new(active_user) }

      before { Plink::UserService.stub(:new).and_return(user_service) }

      it "sends the attributes to deactivate a user" do
        my_time = Time.zone.now
        Time.stub_chain(:zone, :now).and_return(my_time)

        deactivation_params = {
          is_force_deactivated: '1',
          deactivation_date: my_time,
          email: 'resetByAdmin_test@test.com',
          password_hash: 'resetByAdmin_HASH'
        }

        active_user.should_receive(:update_attributes).with(deactivation_params).and_return(true)

        update_manager.update_attributes(params)
      end

      it 'unsubscribes the user from marketing and contest emails' do
        unsub_params = {is_subscribed: '0', daily_contest_reminder: '0'}

        user_service.should_receive(:update_subscription_preferences).with(100, unsub_params)

        update_manager.update_attributes(params)
      end
    end

    context 'when reactivating a user' do
      let(:inactive_user) {
        new_user(
          {
            id: 100,
            daily_contest_reminder: false,
            deactivation_date: Time.zone.now,
            email: 'resetByAdmin_test@test.com',
            is_force_deactivated: true,
            is_subscribed: false,
            password_hash: 'resetByAdmin_HASH'
          }
        )
      }
      let(:params) { {'is_force_deactivated' => '0'} }
      let(:user_service) { double(Plink::UserService, update_subscription_preferences: true) }

      subject(:update_manager) { user_update_with_active_state_manager.new(inactive_user) }

      before { Plink::UserService.stub(:new).and_return(user_service) }

      it 'sends the attributes to reactivate a user' do
        reactivation_params = {
          is_force_deactivated: '0',
          deactivation_date: nil,
          email: 'test@test.com',
          password_hash: 'HASH'
        }

        inactive_user.should_receive(:update_attributes).with(reactivation_params).and_return(true)

        update_manager.update_attributes(params)
      end

      it 'subscribes the user to marketing and contest emails' do
        subscribe_params = {is_subscribed: '1', daily_contest_reminder: '1'}

        user_service.should_receive(:update_subscription_preferences).with(100, subscribe_params)

        update_manager.update_attributes(params)
      end
    end

    context 'when force deactivation state is not changing' do
      let(:active_user) {
        new_user(
          {
            id: 100,
            daily_contest_reminder: true,
            deactivation_date: nil,
            email: 'test@test.com',
            is_force_deactivated: false,
            is_subscribed: true,
            password_hash: 'HASH'
          }
        )
      }
      let(:params) { {'is_force_deactivated' => '0'} }
      let(:user_service) { double(Plink::UserService) }

      subject(:update_manager) { user_update_with_active_state_manager.new(active_user) }

      it 'does not change the parameters' do
        update_params = { is_force_deactivated: '0' }

        active_user.should_receive(:update_attributes).with(update_params).and_return(true)

        update_manager.update_attributes(params)
      end

      it "does not change the user's email subscription" do
        user_service.should_not_receive(:update_subscription_preferences)

        update_manager.update_attributes(params)
      end
    end
  end
end
