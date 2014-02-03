module Plink
  class BrandCompetitorRecord < ActiveRecord::Base
    self.table_name = 'brand_competitors'

    attr_accessible :brand_id, :competitor, :competitor_id, :default

    belongs_to :brand, class_name: 'Plink::BrandRecord'
    belongs_to :competitor, class_name: 'Plink::BrandRecord'
  end
end
