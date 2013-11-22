module Plink
  class HeroPromotionClickRecord < ActiveRecord::Base
    self.table_name = 'hero_promotion_clicks'

    attr_accessible :hero_promotion_id, :image, :user_id

    validates_presence_of :hero_promotion_id, :user_id
  end
end
