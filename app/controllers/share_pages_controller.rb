class SharePagesController < ApplicationController
  def show
    @affiliate_id = Rails.application.config.default_contest_affiliate_id
    @share_page = Plink::SharePageRecord.find(params[:id])
    @user = current_user
  end
end
