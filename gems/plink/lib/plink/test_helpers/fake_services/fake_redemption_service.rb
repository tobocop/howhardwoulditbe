require 'plink/test_helpers/object_creation_methods'

module Plink
  class FakeRedemptionService

    include ObjectCreationMethods

    def create_pending(args = {})
      if @fail
        false
      else
        true
      end
    end

    def set_fail(flag)
      @fail = flag
    end
  end
end