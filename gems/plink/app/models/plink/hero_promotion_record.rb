module Plink
  class HeroPromotionRecord < ActiveRecord::Base

    self.table_name = 'hero_promotions'

    attr_accessible :image_url, :title, :display_order, :is_active, :name

    validates_presence_of :title, :image_url

    scope :by_display_order, lambda { order(:display_order) }

  end
end

