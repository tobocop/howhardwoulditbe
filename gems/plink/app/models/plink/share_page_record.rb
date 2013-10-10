module Plink
  class SharePageRecord < ActiveRecord::Base
    self.table_name = 'share_pages'

    attr_accessible :name, :partial_path

    validates_presence_of :name, :partial_path
  end
end

