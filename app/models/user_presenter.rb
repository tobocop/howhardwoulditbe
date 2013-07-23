class UserPresenter
  DEFAULT_AVATAR_THUMBNAIL_PATH = 'silhouette.jpg'
  FIRST_NAME_DISPLAY_LENGTH = 13

  attr_accessor :user

  def initialize(options = {})
    self.user = options.fetch(:user)
  end

  def id
    user.id
  end

  def email
    user.email
  end

  def logged_in?
    true
  end

  def primary_virtual_currency_id
    user.primary_virtual_currency_id
  end

  def current_balance
    user.current_balance
  end

  def lifetime_balance
    user.lifetime_balance
  end

  def can_redeem?
    user.can_redeem?
  end

  def first_name
    user.first_name[0..FIRST_NAME_DISPLAY_LENGTH]
  end

  def wallet
    Plink::Wallet.new(user.wallet)
  end

  def open_wallet_item
    user.open_wallet_item
  end

  def avatar_thumbnail_url
    if user.avatar_thumbnail_url.blank?
      DEFAULT_AVATAR_THUMBNAIL_PATH
    else
      user.avatar_thumbnail_url
    end
  end
end