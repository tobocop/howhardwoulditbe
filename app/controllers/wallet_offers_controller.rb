class WalletOffersController < ApplicationController
  before_filter :require_authentication

  def create
    offer = Plink::OfferRecord.live_only(params[:offer_id])
    service = Plink::AddOfferToWalletService.new(user: current_user, offer: offer)

    if service.add_offer
      redirect_to wallet_path
    else
      render nothing: true, status: :internal_server_error
    end
  end
end