module PlinkAdmin
  class GlobalLoginTokensController < ApplicationController
    def index
      @global_login_tokens = Plink::GlobalLoginTokenRecord.where('expires_at > ?', 7.days.ago).order('expires_at ASC')
    end

    def new
      @global_login_token = Plink::GlobalLoginTokenRecord.new
    end

    def create
      @global_login_token = Plink::GlobalLoginTokenRecord.create(params[:global_login_token])

      if @global_login_token.persisted?
        flash[:notice] = 'Global login token created successfully'
        redirect_to plink_admin.global_login_tokens_path
      else
        flash.now[:notice] = 'Global login token could not be created'
        render 'new'
      end
    end

    def edit
      @global_login_token = Plink::GlobalLoginTokenRecord.find(params[:id])
    end

    def update
      @global_login_token = Plink::GlobalLoginTokenRecord.find(params[:id])

      if @global_login_token.update_attribute('redirect_url', params[:global_login_token][:redirect_url])
        flash[:notice] = 'Global login token updated'
        redirect_to plink_admin.global_login_tokens_path
      else
        flash.now[:notice] = 'Global login token could not be updated'
        render 'edit'
      end
    end
  end
end
