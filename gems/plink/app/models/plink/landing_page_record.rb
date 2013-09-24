module Plink
  class LandingPageRecord < ActiveRecord::Base

    self.table_name = 'landing_pages'

    attr_accessible :name, :partial_path

    validates_presence_of :partial_path, :name

  end
end

