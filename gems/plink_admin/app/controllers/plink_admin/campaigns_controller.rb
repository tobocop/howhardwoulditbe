module PlinkAdmin
  class CampaignsController < ApplicationController
    require 'digest/sha1'

    def index
      @campaigns = Plink::CampaignRecord.all
    end

    def new
      @campaign = Plink::CampaignRecord.new
    end

    def create
      @campaign = Plink::CampaignRecord.create(campaign_params)

      if @campaign.persisted?
        flash[:notice] = 'Campaign created successfully'
        redirect_to campaigns_path
      else
        flash.now[:notice] = 'Campaign could not be created'
        render 'new'
      end
    end

    def edit
      @campaign = Plink::CampaignRecord.find(params[:id])
    end

    def update
      @campaign = Plink::CampaignRecord.find(params[:id])

      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = 'Campaign updated'
        redirect_to campaigns_path
      else
        flash.now[:notice] = 'Campaign could not be updated'
        render 'edit'
      end
    end

  private

    def campaign_params
      campaign_params = params[:campaign]
      campaign_params.merge(campaign_hash: Digest::SHA1.hexdigest(params[:campaign][:name]))
    end
  end
end
