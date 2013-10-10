module PlinkAdmin
  module ApplicationHelper
    def present_as_date(time)
      return if time.nil?

      time.strftime('%-m/%-d/%y')
    end
  end
end
