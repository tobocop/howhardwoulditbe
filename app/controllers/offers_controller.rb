class OffersController < ApplicationController

  layout 'logged_out'

  def index
    @offers = Plink::Offer.all
  end
end
