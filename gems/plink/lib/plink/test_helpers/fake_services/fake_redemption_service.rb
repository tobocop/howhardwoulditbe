module Plink
  class FakeRedemptionService

    def create(args = {})
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