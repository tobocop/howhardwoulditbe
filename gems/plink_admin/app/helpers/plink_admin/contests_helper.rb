module PlinkAdmin
  module ContestsHelper

    def present_date(time)
      return if time.nil?

      time.strftime('%-m/%-d/%y')
    end

    def present_column_name(name)
      name.gsub('_', ' ').titleize
    end
  end
end
