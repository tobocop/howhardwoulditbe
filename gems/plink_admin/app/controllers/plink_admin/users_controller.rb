module PlinkAdmin
  class UsersController < ApplicationController

    def index
      @users = []
    end

    def search
      @search_term = params[:email]
      @users = plink_user_service.search_by_email(@search_term)
      render :index
    end

    private

    def plink_user_service
      @plink_user_service ||= Plink::UserService.new
    end
  end
end