module Plink
  class IntuitRequestRecord < ActiveRecord::Base
    self.table_name = 'intuit_requests'

    attr_accessible :processed, :response, :user_id
  end
end
