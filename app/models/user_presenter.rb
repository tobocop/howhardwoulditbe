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

  def first_name
    user.first_name
  end

  def avatar_thumbnail_url
    if user.avatar_thumbnail_url.blank?
      DEFAULT_AVATAR_THUMBNAIL_PATH
    else
      user.avatar_thumbnail_url
    end
  end
end