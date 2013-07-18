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
      render json: {failure_reason: 'wallet_full'}, status: :ok
    end
  end

  def destroy
    offer = Plink::OfferRecord.find(params[:id])
    removal_service = Plink::RemoveOfferFromWalletService.new(user: current_user, offer: offer)
    if removal_service.remove_offer
      render json: {wallet: presented_wallet_items, removed_wallet_item: removed_wallet_item(offer)}
    else
      render nothing: true, status: :internal_server_error
    end
  end

  private

  def removed_wallet_item(offer_record)
    user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    offer = Plink::Offer.new(offer_record, current_virtual_currency.id)
    OfferItemPresenter.new(offer, virtual_currency: current_virtual_currency, view_context: self.view_context, linked: user_has_account, signed_in: current_user.logged_in?)
  end

end