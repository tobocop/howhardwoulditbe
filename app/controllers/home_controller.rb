class HomeController < ApplicationController
  def index
    logger.info "FLASH ----------"
    logger.info flash[:notice]
  end
end