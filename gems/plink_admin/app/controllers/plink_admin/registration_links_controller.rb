module PlinkAdmin
  class RegistrationLinksController < ApplicationController

    def index
      @registration_links = Plink::RegistrationLinkRecord.all
    end

    def new
      @registration_link = Plink::RegistrationLinkRecord.new
      @affiliates = Plink::AffiliateRecord.all
      @campaigns = Plink::CampaignRecord.all
      @landing_pages = Plink::LandingPageRecord.all
    end

    def create
      if params[:affiliate_ids]
        registration_link_params = {
            campaign_id: params[:campaign_id],
            is_active: params[:is_active],
            start_date: parse_date('start_date'),
            end_date: parse_date('end_date'),
            landing_page_records: landing_pages(params[:landing_page_ids])
        }

        params[:affiliate_ids].each do |affiliate_id|
          Plink::RegistrationLinkRecord.create(registration_link_params.merge(affiliate_id: affiliate_id))
        end

        redirect_to registration_links_path
      else
        flash[:notice] = 'You cannot create links without affiliates'
        redirect_to new_registration_link_path
      end
    end

  private
    
    def landing_pages(landing_page_ids)
      landing_page_ids ? Plink::LandingPageRecord.find(landing_page_ids) : []
    end

    def parse_date(params_key)
      Time.zone.local(
        params["#{params_key}"][:"#{params_key}(1i)"].to_i,
        params["#{params_key}"][:"#{params_key}(2i)"].to_i,
        params["#{params_key}"][:"#{params_key}(3i)"].to_i
      )
    end
  end
end
