module PlinkAdmin
  class UserUpdateWithActiveStateManager
    attr_accessor :user_record

    def initialize(user_record)
      raise ArgumentError unless user_record.is_a?(Plink::UserRecord)
      @user_record = user_record
    end

    def update_attributes(params)
      user_params = params.to_h.symbolize_keys
      deactivating = user_params[:is_force_deactivated] == '1' ? true : false

      if @user_record.is_force_deactivated != deactivating
        user_params.merge!(active_state_params(deactivating))
        update_subscriptions(user_params)
      end

      @user_record.update_attributes(user_params)
    end

  private

    def active_state_params(deactivating)
      deactivating ? deactivation_params : reactivation_params
    end

    def deactivation_params
      {
        deactivation_date: Time.zone.now,
        password_hash: 'resetByAdmin_' + @user_record.password_hash,
        email: 'resetByAdmin_' + @user_record.email
      }
    end

    def reactivation_params
      {
        deactivation_date: nil,
        password_hash: @user_record.password_hash.gsub(/resetByAdmin_/,''),
        email: @user_record.email.gsub(/resetByAdmin_/,'')
      }
    end

    def update_subscriptions(user_params)
      subscribed = user_params[:is_force_deactivated] == '0' ? '1':'0'
      preferences = {is_subscribed: subscribed, daily_contest_reminder: subscribed}
      plink_user_service.update_subscription_preferences(@user_record.id, preferences)
    end

    def plink_user_service
      Plink::UserService.new(true)
    end
  end
end
