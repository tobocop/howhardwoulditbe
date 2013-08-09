module PlinkAdmin
  class UsersController < ApplicationController

    def index
      @users = []
    end

    def edit
      @user = Plink::UserRecord.find(params[:id])
    end

    def search
      @search_term = params[:email]
      @users = plink_user_service.search_by_email(@search_term)
      render :index
    end

    def impersonate
      PlinkAdmin.sign_in_user.call(params[:id], session)
      redirect_to PlinkAdmin.impersonation_redirect_url
    end

    def stop_impersonating
      PlinkAdmin.sign_out_user.call(session)
      redirect_to plink_admin.root_path
    end

    private

    def plink_user_service
      @plink_user_service ||= Plink::UserService.new
    end
  end
end
