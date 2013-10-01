module PlinkAdmin
  class OffersController < ApplicationController

    def index
      @offers = Plink::OfferRecord.all
    end

    def edit
      @offer = Plink::OfferRecord.find(params[:id])
    end

    def update
      @offer = Plink::OfferRecord.find(params[:id])

      if @offer.update_attribute(:end_date, parse_date('end_date'))
        flash[:notice] = 'Offer end date updated'
        redirect_to offers_path
      else
        flash.now[:notice] = 'Offer could not be updated'
        render 'edit'
      end
    end

  private

    def parse_date(params_key)
      Time.zone.local(
        params[:offer][:"#{params_key}(1i)"].to_i,
        params[:offer][:"#{params_key}(2i)"].to_i,
        params[:offer][:"#{params_key}(3i)"].to_i
      )
    end
  end
end
