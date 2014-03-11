module PlinkAdmin
  class AwardLinksController < PlinkAdmin::ApplicationController

    def index
      @award_links = Plink::AwardLinkRecord.all
    end

    def new
      @award_link = Plink::AwardLinkRecord.new
      get_data
    end

    def create
      @award_link = Plink::AwardLinkRecord.create(params[:award_link])

      if @award_link.persisted?
        flash[:notice] = 'Award link created successfully'
        redirect_to plink_admin.award_links_path
      else
        get_data
        flash.now[:notice] = 'Award link could not be created'
        render 'new'
      end
    end

    def edit
      @award_link = Plink::AwardLinkRecord.find(params[:id])
      get_data
    end

    def update
      @award_link = Plink::AwardLinkRecord.find(params[:id])

      if @award_link.update_attributes(params[:award_link])
        flash[:notice] = 'Award link updated'
        redirect_to plink_admin.award_links_path
      else
        get_data
        flash.now[:notice] = 'Award link could not be updated'
        render 'edit'
      end
    end

  private

    def get_data
      @award_types = Plink::AwardTypeRecord.all
    end
  end
end
