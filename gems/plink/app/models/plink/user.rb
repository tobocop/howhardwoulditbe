module Plink
  class User

    attr_reader :new_user, :user_record, :errors

    def initialize(attributes)
      @new_user = attributes.fetch(:new_user)
      @user_record = attributes.fetch(:user_record)
      @errors = attributes.fetch(:errors, [])
    end

    delegate :avatar_thumbnail_url, :can_redeem?, :currency_balance, :current_balance,
      :daily_contest_reminder, :email, :first_name, :id, :is_subscribed, :lifetime_balance,
      :open_wallet_item, :opt_in_to_daily_contest_reminders!, :password_hash, :primary_virtual_currency_id, :provider, :salt,
      :update_attributes, :wallet, to: :user_record

    def new_user?
      new_user
    end

    def valid?
      errors.empty?
    end

    def avatar_thumbnail_url?
      avatar_thumbnail_url
    end

  end
end
