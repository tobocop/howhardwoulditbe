class HeroPromotion < ActiveRecord::Base

  attr_accessible :image_url, :title, :display_order

  scope :by_display_order, lambda { order(:display_order) }

end