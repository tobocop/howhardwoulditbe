module PlinkAdmin
  class ReceiptPromotionsController < PlinkAdmin::ApplicationController

    def index
      @receipt_promotions = Plink::ReceiptPromotionRecord.all
    end

    def new
      @receipt_promotion = Plink::ReceiptPromotionRecord.new
      get_data
    end

    def create
      @receipt_promotion = Plink::ReceiptPromotionRecord.create(params[:receipt_promotion])

      if @receipt_promotion.persisted?
        flash[:notice] = 'Receipt promotion created successfully'
        redirect_to plink_admin.receipt_promotions_path
      else
        get_data
        flash.now[:notice] = 'Receipt promotion could not be created'
        render 'new'
      end
    end

    def edit
      @receipt_promotion = Plink::ReceiptPromotionRecord.find(params[:id])
      get_data
    end

    def update
      @receipt_promotion = Plink::ReceiptPromotionRecord.find(params[:id])

      if @receipt_promotion.update_attributes(params[:receipt_promotion])
        flash[:notice] = 'Receipt promotion updated'
        redirect_to plink_admin.receipt_promotions_path
      else
        get_data
        flash.now[:notice] = 'Receipt promotion could not be updated'
        render 'edit'
      end
    end

  private

    def get_data
      @award_types = Plink::AwardTypeRecord.all
      @receipt_promotion.receipt_promotion_postback_urls.build
      @registration_links = Plink::RegistrationLinkRecord.all
      @advertisers = Plink::AdvertiserRecord.order('advertiserName ASC').all
    end
  end
end
