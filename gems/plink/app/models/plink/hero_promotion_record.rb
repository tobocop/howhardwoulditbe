module Plink
  class HeroPromotionRecord < ActiveRecord::Base
    self.table_name = 'hero_promotions'

    attr_accessible :display_order, :image_url, :is_active, :name, :show_linked_users,
      :show_non_linked_users, :title

    validates_presence_of :title, :image_url, :name

    def self.by_display_order
      order(:display_order)
    end

    def self.active
      where(is_active: true)
    end
  end
end

