module PlinkAdmin
  module ContestsHelper
    def present_column_name(name)
      name.gsub('_', ' ').titleize
    end
  end
end
