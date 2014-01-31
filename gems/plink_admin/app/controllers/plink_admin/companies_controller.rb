module PlinkAdmin
  class CompaniesController < ApplicationController

    def index
      @companies = Plink::CompanyRecord.all
    end

    def new
      company_data
      @company = Plink::CompanyRecord.new
    end

    def create
      @company = Plink::CompanyRecord.create(params[:company])

      if @company.persisted?
        flash[:notice] = 'Company created successfully'
        redirect_to companies_path
      else
        company_data
        flash.now[:notice] = 'Company could not be created'
        render 'new'
      end
    end

    def edit
      company_data
      @company = Plink::CompanyRecord.find(params[:id])
    end

    def update
      @company = Plink::CompanyRecord.find(params[:id])

      if @company.update_attributes(params[:company])
        flash[:notice] = 'Company updated'
        redirect_to companies_path
      else
        company_data
        flash.now[:notice] = 'Company could not be updated'
        render 'edit'
      end
    end

  private

    def company_data
      @advertisers = Plink::AdvertiserRecord.order(:advertiserName).all
      @sales_reps = Plink::SalesRepRecord.order(:name).all
    end
  end
end
