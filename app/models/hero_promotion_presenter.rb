class HeroPromotionPresenter
  attr_reader :hero_promotion, :user_id

  def initialize(hero_promotion, user_id)
    @hero_promotion = hero_promotion
    @user_id = user_id
  end

  delegate :id, :title, to: :hero_promotion

  def left_and_right_promotion?
    hero_promotion.image_url_two.present?
  end

  def link_target_for_left_url
    hero_promotion.same_tab_one ? '_self' : '_blank'
  end

  def link_target_for_right_url
    hero_promotion.same_tab_two ? '_self' : '_blank'
  end

  def image_url_left
    hero_promotion.image_url_one
  end

  def image_url_right
    hero_promotion.image_url_two
  end

  def link_left
    hero_promotion.link_one
  end

  def link_right
    hero_promotion.link_two
  end
end
