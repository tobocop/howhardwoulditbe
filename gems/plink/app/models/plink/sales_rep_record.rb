module Plink
  class SalesRepRecord < ActiveRecord::Base
    self.table_name = 'sales_reps'

    attr_accessible :name
  end
end
