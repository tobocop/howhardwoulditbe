module Plink
  class User

    attr_reader :new_user, :user_record

    def initialize(attributes)
      @new_user = attributes.fetch(:new_user)
      @user_record = attributes.fetch(:user_record)
    end

    delegate :id,
             :first_name,
             :email,
             :current_balance,
             :lifetime_balance,
             :can_redeem?,
             :wallet,
             :avatar_thumbnail_url,
             :salt,
             :password_hash,
             :primary_virtual_currency_id,
             :open_wallet_item,
             to: :user_record

    def new_user?
      new_user
    end

    def avatar_thumbnail_url?
      avatar_thumbnail_url
    end


  end
end