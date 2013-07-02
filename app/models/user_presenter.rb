class UserPresenter
  DEFAULT_AVATAR_THUMBNAIL_PATH = 'silhouette.jpg'

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
    user.first_name
  end

  def wallet_items
    user.wallet_items.map { |item| Plink::WalletItem.new(item) }
  end

  def avatar_thumbnail_url
    if user.avatar_thumbnail_url.blank?
      DEFAULT_AVATAR_THUMBNAIL_PATH
    else
      user.avatar_thumbnail_url
    end
  end

  def empty_wallet_item
    user.empty_wallet_item
  end
end