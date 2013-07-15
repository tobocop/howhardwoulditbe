class WalletOffersController < ApplicationController
  include WalletExtensions

  before_filter :require_authentication
  before_filter :user_must_be_linked

  def create
    offer = Plink::OfferRecord.live_only(params[:offer_id])
    service = Plink::AddOfferToWalletService.new(user: current_user, offer: offer)

    if service.add_offer
      render json: {wallet: presented_wallet_items}, status: :created
    else
      render nothing: true, status: :internal_server_error
    end
  end

  def destroy
    offer = Plink::OfferRecord.find(params[:id])
    Plink::RemoveOfferFromWalletService.new(user: current_user, offer: offer).remove_offer
    render json: {wallet: presented_wallet_items, removed_wallet_item: {}}
  end
end