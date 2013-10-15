class SharePagesController < ApplicationController
  def show
    @share_page = Plink::SharePageRecord.find(params[:id])
  end
end
