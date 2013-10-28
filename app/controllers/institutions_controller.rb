class InstitutionsController < ApplicationController
  before_filter :require_authentication
  before_filter :most_popular

  def search
    redirect_to wallet_path(link_card: true) if Rails.env.production?
  end

  def search_results
    flash.clear

    if params[:institution_name].blank?
      flash[:error] = 'Please provide a bank name or URL'
    else
      @results = Plink::InstitutionRecord.search(params[:institution_name])
    end
  end

  def authorization_form
    @institution = Plink::InstitutionRecord.where(institutionID: params[:id])

    if @institution.blank?
      flash[:error] = 'Invalid institution provided. Please try again.'
      redirect_to institution_search_path
    end
  end

private

  def most_popular
    @most_popular ||= Plink::InstitutionRecord.most_popular
  end
end
