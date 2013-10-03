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
      render json: {failure_reason: 'wallet_full'}, status: :forbidden
    end
  end

  def destroy
    removal_service = Plink::RemoveOfferFromWalletService.new(current_user.id, offer_id)
    if removal_service.remove_offer
      offer = Plink::OfferRecord.find(offer_id)
      render json: {wallet: presented_wallet_items, removed_wallet_item: removed_wallet_item(offer)}
    else
      render nothing: true, status: :internal_server_error
    end
  end

private

  def offer_id
    params[:id].to_i
  end

  def removed_wallet_item(offer_record)
    user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    offer = Plink::Offer.new(
      offer_record: offer_record,
      virtual_currency_id: current_virtual_currency.id,
      name: offer_record.advertiser.advertiser_name,
      image_url: offer_record.advertiser.logo_url,
      is_new: offer_record.is_new,
      is_promotion: offer_record.active_offers_virtual_currencies.first.try(:is_promotion)
    )
    OfferItemPresenter.new(offer, virtual_currency: current_virtual_currency, view_context: self.view_context, linked: user_has_account, signed_in: current_user.logged_in?)
  end

end