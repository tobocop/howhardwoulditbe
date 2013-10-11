module PlinkAdmin
  class RegistrationLinksController < ApplicationController

    def index
      @registration_links = Plink::RegistrationLinkRecord.all
    end

    def new
      registration_link_data
      @registration_link = Plink::RegistrationLinkRecord.new
    end

    def create
      if params[:affiliate_ids]
        registration_link_params = {
          campaign_id: params[:campaign_id],
          is_active: params[:is_active],
          share_flow: params[:share_flow],
          start_date: parse_date('start_date'),
          end_date: parse_date('end_date'),
          landing_page_records: landing_pages(params[:landing_page_ids]),
          share_page_records: share_pages(params[:share_page_ids])
        }

        registration_links = params[:affiliate_ids].map do |affiliate_id|
          Plink::RegistrationLinkRecord.create(registration_link_params.merge(affiliate_id: affiliate_id))
        end
        @error = extract_errors(registration_links)

        if @error.present?
          registration_link_data
          flash[:notice] = 'Failed to create one or more registration links'
          render :new
        else
          flash[:notice] = "Successfully created #{registration_links.size} registration link(s)"
          redirect_to registration_links_path
        end
      else
        registration_link_data
        flash[:notice] = 'Failed to create any registration links'
        @error = 'Please select an affiliate'
        render :new
      end
    end

    def edit
      registration_link_data
      @registration_link = Plink::RegistrationLinkRecord.find(params[:id])
      @landing_pages = Plink::LandingPageRecord.all
    end

    def update
      @registration_link = Plink::RegistrationLinkRecord.find(params[:id])
      update_params = {
        is_active: params[:is_active],
        start_date: parse_date('start_date'),
        end_date: parse_date('end_date'),
        landing_page_records: landing_pages(params[:landing_page_ids]),
        share_page_records: share_pages(params[:share_page_ids]),
        share_flow: params[:share_flow]
      }

      if @registration_link.update_attributes(update_params)
        flash[:notice] = 'Registration link updated'
        redirect_to registration_links_path
      else
        registration_link_data
        @error = extract_errors(Array(@registration_link))
        flash[:notice] = 'Could not update registration link'
        render :edit
      end
    end

  private

    def registration_link_data
      @affiliates = Plink::AffiliateRecord.all
      @campaigns = Plink::CampaignRecord.all
      @landing_pages = Plink::LandingPageRecord.all
      @share_pages = Plink::SharePageRecord.all
    end

    def landing_pages(landing_page_ids)
      landing_page_ids ? Plink::LandingPageRecord.find(landing_page_ids) : []
    end

    def share_pages(share_page_ids)
      share_page_ids ? Plink::SharePageRecord.find(share_page_ids) : []
    end

    def parse_date(params_key)
      Time.zone.local(
        params[params_key][:"#{params_key}(1i)"].to_i,
        params[params_key][:"#{params_key}(2i)"].to_i,
        params[params_key][:"#{params_key}(3i)"].to_i
      )
    end

    def extract_errors(registration_links)
      error_messages = registration_links.map{ |reg_link| reg_link.errors.full_messages }

      error_messages.join(', ') if error_messages.any? { |error| error.present? }
    end
  end
end
