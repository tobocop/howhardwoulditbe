module Plink
  class CompanyRecord < ActiveRecord::Base
    self.table_name = 'companies'

    attr_accessible :advertiser_id, :name, :prospect, :sales_rep_id, :vanity_url

    belongs_to :sales_rep, class_name: 'Plink::SalesRepRecord'

    validates_presence_of :advertiser_id, :name, :sales_rep_id, :vanity_url
  end
end
