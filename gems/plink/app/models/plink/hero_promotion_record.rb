module Plink
  class HeroPromotionRecord < ActiveRecord::Base

    self.table_name = 'hero_promotions'

    attr_accessible :image_url, :title, :display_order, :is_active, :name

    validates_presence_of :title, :image_url, :name

    def self.by_display_order
      order(:display_order)
    end

    def self.active
      self.where(is_active: true)
    end
  end
end

