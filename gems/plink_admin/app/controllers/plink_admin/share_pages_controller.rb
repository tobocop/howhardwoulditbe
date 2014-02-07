module PlinkAdmin
  class SharePagesController < ApplicationController

    def index
      @share_pages = Plink::SharePageRecord.all
    end

    def new
      @share_page = Plink::SharePageRecord.new
    end

    def create
      @share_page = Plink::SharePageRecord.create(params[:share_page])

      if @share_page.persisted?
        flash[:notice] = 'Share page created successfully'
        redirect_to plink_admin.share_pages_path
      else
        flash.now[:notice] = 'Share page could not be created'
        render 'new'
      end
    end

    def edit
      @share_page = Plink::SharePageRecord.find(params[:id])
    end

    def update
      @share_page = Plink::SharePageRecord.find(params[:id])

      if @share_page.update_attributes(params[:share_page])
        flash[:notice] = 'Share page updated'
        redirect_to plink_admin.share_pages_path
      else
        flash.now[:notice] = 'Share page could not be updated'
        render 'edit'
      end
    end
  end
end
