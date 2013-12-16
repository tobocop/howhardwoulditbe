module PlinkAdmin
  class HeroPromotionsController < ApplicationController

    def index
      @hero_promotions = plink_hero_promotion_record.select(index_fields).order('created_at DESC')
    end

    def new
      @hero_promotion = plink_hero_promotion_record.new
    end

    def create
      hero_promotion_params = params[:hero_promotion]
      hero_promotion_params[:user_ids] = parse_from_file(params[:hero_promotion][:user_ids])

      @hero_promotion = plink_hero_promotion_record.create(hero_promotion_params)

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

    def edit_audience
      @hero_promotion = plink_hero_promotion_record.find(params[:id])
    end

    def update_audience
      hero_promotion_params = params[:hero_promotion]
      hero_promotion_params[:user_ids] = parse_from_file(params[:hero_promotion][:user_ids])

      @hero_promotion = plink_hero_promotion_record.find(params[:id])

      if @hero_promotion.update_attributes(hero_promotion_params)
        redirect_to hero_promotions_path
      else
        render 'edit_audience'
      end
    end

    private

    def plink_hero_promotion_record
      Plink::HeroPromotionRecord
    end

    def parse_from_file(user_ids_file)
      result = {}
      return result unless user_ids_file.present?

      File.open(user_ids_file.tempfile, 'r') do |f|
        f.each_line do |line|
          result[line.strip.to_i] = true
        end
      end

      result
    end

    def index_fields
      [:display_order, :id, :image_url_one, :image_url_two, :is_active, :name, :title]
    end
  end
end
