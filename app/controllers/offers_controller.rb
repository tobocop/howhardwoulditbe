class OffersController < ApplicationController

  layout 'logged_out'

  def index
    @offers = plink_offer_service.get_offers(current_virtual_currency.id)
  end

  private

  def plink_offer_service
    @offer_service ||= Plink::OfferService.new
  end
end
