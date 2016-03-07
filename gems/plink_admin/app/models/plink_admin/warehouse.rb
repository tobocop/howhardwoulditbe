module PlinkAdmin
  class Warehouse < ActiveRecord::Base
    self.abstract_class = true
    #establish_connection "redshift_#{Rails.env}"
  end
end
