module Plink
  class IntuitAccountRequestRecord < ActiveRecord::Base
    self.table_name = 'intuit_account_requests'

    attr_accessible :processed, :response, :user_id
  end
end
