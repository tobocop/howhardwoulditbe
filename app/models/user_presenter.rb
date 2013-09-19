class UserPresenter
  DEFAULT_AVATAR_THUMBNAIL_PATH = 'silhouette.jpg'
  FIRST_NAME_DISPLAY_LENGTH = 13

  attr_accessor :user

  def initialize(options = {})
    self.user = options.fetch(:user)
  end

  delegate :currency_balance, :can_redeem?, :current_balance, :daily_contest_reminder, :email,
    :id, :lifetime_balance, :open_wallet_item, :opt_in_to_daily_contest_reminders!,
    :primary_virtual_currency_id, :provider, to: :user

  def logged_in?
    true
  end

  def points_until_next_redemption
    if currency_balance < 500
      500 - currency_balance
    else
      1000 - currency_balance
    end
  end

  def first_name
    user.first_name[0..FIRST_NAME_DISPLAY_LENGTH]
  end

  def is_subscribed?
    user.is_subscribed
  end

  def wallet
    Plink::Wallet.new(user.wallet)
  end

  def avatar_thumbnail_url
    if user.avatar_thumbnail_url.blank?
      DEFAULT_AVATAR_THUMBNAIL_PATH
    else
      user.avatar_thumbnail_url
    end
  end

end
