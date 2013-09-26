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
      @error = params[:error]
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

        flash[:notice] = 'Successfully created one or more registration links'

        redirect_to registration_links_path
      else
        flash[:notice] = 'Failed to create one or more registration links'
        redirect_to new_registration_link_path(error: 'You cannot create links without selecting an affiliate')
      end
    end

    def edit
      @registration_link = Plink::RegistrationLinkRecord.find(params[:id])
      @landing_pages = Plink::LandingPageRecord.all
    end

    def update
      registration_link = Plink::RegistrationLinkRecord.find(params[:id])
      update_params = {
        is_active: params[:is_active],
        start_date: parse_date('start_date'),
        end_date: parse_date('end_date'),
        landing_page_records: landing_pages(params[:landing_page_ids])
      }

      if registration_link.update_attributes(update_params)
        flash[:notice] = 'Registration link updated'
        redirect_to registration_links_path
      else
        flash[:notice] = 'Could not update registration link'
        redirect_to edit_registration_link_path(registration_link)
      end
    end

  private
    
    def landing_pages(landing_page_ids)
      landing_page_ids ? Plink::LandingPageRecord.find(landing_page_ids) : []
    end

    def parse_date(params_key)
      Time.zone.local(
        params[params_key][:"#{params_key}(1i)"].to_i,
        params[params_key][:"#{params_key}(2i)"].to_i,
        params[params_key][:"#{params_key}(3i)"].to_i
      )
    end
  end
end
