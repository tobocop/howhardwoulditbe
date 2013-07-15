module PlinkAdmin
  class HeroPromotionsController < ApplicationController
    def new
      @hero_promotion = plink_hero_promotion_record.new
    end

    def create
      @hero_promotion = plink_hero_promotion_record.create(params[:hero_promotion])

      if @hero_promotion.persisted?
        redirect_to hero_promotions_path
      else
        render template: 'plink_admin/hero_promotions/new'
      end
    end

    private

    def plink_hero_promotion_record
      Plink::HeroPromotionRecord
    end
  end
end