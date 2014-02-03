module Plink
  class BrandRecord < ActiveRecord::Base
    self.table_name = 'brands'

    attr_accessible :brand_competitors_attributes, :name, :prospect, :sales_rep_id, :vanity_url

    belongs_to :sales_rep, class_name: 'Plink::SalesRepRecord'
    has_many :brand_competitors, class_name: 'Plink::BrandCompetitorRecord', foreign_key: :brand_id
    has_many :competitors, through: :brand_competitors

    accepts_nested_attributes_for :brand_competitors, allow_destroy: true

    validates_presence_of :name, :sales_rep_id, :vanity_url
  end
end
