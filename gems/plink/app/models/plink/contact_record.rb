module Plink
  class ContactRecord < ActiveRecord::Base
    self.table_name = 'contacts'

    attr_accessible :brand_id, :email, :first_name, :is_active, :last_name

    belongs_to :brand, class_name: 'Plink::BrandRecord'

    validates_presence_of :brand_id, :email, :first_name, :last_name
  end
end
