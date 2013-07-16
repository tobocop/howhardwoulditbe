module PlinkAdmin
  class HeroPromotionsController < ApplicationController

    def index
      @hero_promotions = plink_hero_promotion_record.order('created_at DESC')
    end

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

    def edit
      @hero_promotion = plink_hero_promotion_record.find(params[:id])
    end

    def update
      @hero_promotion = plink_hero_promotion_record.find(params[:id])

      if @hero_promotion.update_attributes(params[:hero_promotion])
        redirect_to hero_promotions_path
      else
        render 'edit'
      end
    end

    private

    def plink_hero_promotion_record
      Plink::HeroPromotionRecord
    end
  end
end