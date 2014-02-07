module PlinkAdmin
  class BrandsController < ApplicationController

    def index
      @brands = Plink::BrandRecord.all
    end

    def new
      @brand = Plink::BrandRecord.new
      brand_data
    end

    def create
      @brand = Plink::BrandRecord.create(params[:brand])

      if @brand.persisted?
        flash[:notice] = 'Brand created successfully'
        redirect_to plink_admin.brands_path
      else
        brand_data
        flash.now[:notice] = 'Brand could not be created'
        render 'new'
      end
    end

    def edit
      @brand = Plink::BrandRecord.find(params[:id])
      brand_data
    end

    def update
      @brand = Plink::BrandRecord.find(params[:id])

      if @brand.update_attributes(params[:brand])
        flash[:notice] = 'Brand updated'
        redirect_to plink_admin.brands_path
      else
        brand_data
        flash.now[:notice] = 'Brand could not be updated'
        render 'edit'
      end
    end

  private

    def brand_data
      @sales_reps = Plink::SalesRepRecord.order(:name).all
      all_brands
      setup_brand
    end

    def all_brands
      @brands ||= Plink::BrandRecord.order(:name).all
    end

    def setup_brand
      (all_brands - @brand.competitors).each do |competitor|
        @brand.brand_competitors.build(competitor: competitor)
      end
      @brand.brand_competitors.sort_by! {|brand_competitor| brand_competitor.competitor.name }
    end
  end
end
