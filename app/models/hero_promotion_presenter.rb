class HeroPromotionPresenter
  attr_reader :hero_promotion, :user_has_account, :user_id

  def initialize(hero_promotion, user_id, user_has_account)
    @hero_promotion = hero_promotion
    @user_has_account = user_has_account
    @user_id = user_id
  end

  delegate :id, :image_url, :image_url_right, :link, :link_right, :title,
    to: :hero_promotion

  def show_to_current_user?
    hero_promotion.show_in_ui?(user_id, user_has_account)
  end

  def left_and_right_promotion?
    hero_promotion.image_url_right.present?
  end

  def link_target_for_left_url
    hero_promotion.same_tab_one ? '_self' : '_blank'
  end

  def link_target_for_right_url
    hero_promotion.same_tab_two ? '_self' : '_blank'
  end
end
