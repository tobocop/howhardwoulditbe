module PlinkAdmin
  class LandingPagesController < ApplicationController

    def index
      @landing_pages = Plink::LandingPageRecord.all
    end

    def new
      @landing_page = Plink::LandingPageRecord.new
    end

    def create
      @landing_page = Plink::LandingPageRecord.create(params[:landing_page])

      if @landing_page.persisted?
        flash[:notice] = 'Landing page created successfully'
        redirect_to landing_pages_path
      else
        flash.now[:notice] = 'Landing page could not be created'
        render 'new'
      end
    end

    def edit
      @landing_page = Plink::LandingPageRecord.find(params[:id])
    end

    def update
      @landing_page = Plink::LandingPageRecord.find(params[:id])

      if @landing_page.update_attributes(params[:landing_page])
        flash[:notice] = 'Landing page updated'
        redirect_to landing_pages_path
      else
        flash.now[:notice] = 'Landing page could not be updated'
        render 'edit'
      end
    end
  end
end
