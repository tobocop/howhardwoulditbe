module PlinkAdmin
  class CampaignsController < ApplicationController

    def index
      @campaigns = Plink::CampaignRecord.all
    end

    def new
      @campaign = Plink::CampaignRecord.new
    end

    def create
      @campaign = Plink::CampaignRecord.create(params[:campaign])

      if @campaign.persisted?
        redirect_to campaigns_path
      else
        render 'new'
      end
    end

    def edit
      @campaign = Plink::CampaignRecord.find(params[:id])
    end

    def update
      @campaign = Plink::CampaignRecord.find(params[:id])

      if @campaign.update_attributes(params[:campaign])
        redirect_to campaigns_path
      else
        render 'edit'
      end
    end
  end
end
