module Plink
  class FakeHeroPromotionService
    def initialize(promotions)
      @promotions = promotions
    end

    def active_promotions
      @promotions
    end
  end
end