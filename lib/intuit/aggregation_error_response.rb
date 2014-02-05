module Intuit
  class AggregationErrorResponse
    attr_accessor :error_message

    def initialize(error_message)
      @error_message = error_message
    end

    def parse
      {
        error: true,
        value: @error_message
      }
    end
  end
end
