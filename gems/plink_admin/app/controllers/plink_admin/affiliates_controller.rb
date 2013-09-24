module PlinkAdmin
  class AffiliatesController < ApplicationController

    def index
      @affiliates = Plink::AffiliateRecord.all
    end

    def new
      @affiliate = Plink::AffiliateRecord.new
    end

    def create
      @affiliate = Plink::AffiliateRecord.create(affiliate_params)

      if @affiliate.persisted?
        redirect_to affiliates_path
      else
        render 'new'
      end
    end

    def edit
      @affiliate = Plink::AffiliateRecord.find(params[:id])
    end

    def update
      @affiliate = Plink::AffiliateRecord.find(params[:id])

      if @affiliate.update_attributes(affiliate_params)
        redirect_to affiliates_path
      else
        render 'edit'
      end
    end

  private
    
    def affiliate_params
      params[:affiliate].merge!(has_incented_card_registration: true) if valid_card_registration_dollar_award_amount
      params[:affiliate].merge!(has_incented_join: true) if valid_join_dollar_award_amount
      params[:affiliate]
    end

    def valid_card_registration_dollar_award_amount
      params[:affiliate][:card_registration_dollar_award_amount].to_i > 0
    end

    def valid_join_dollar_award_amount
      params[:affiliate][:join_dollar_award_amount].to_i > 0
    end
  end
end
