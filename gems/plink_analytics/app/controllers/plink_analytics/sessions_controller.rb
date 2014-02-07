module PlinkAnalytics
  class SessionsController < ApplicationController
    def new
      @login_form = PlinkAnalytics::LoginForm.new
    end

    def create
      @login_form = PlinkAnalytics::LoginForm.new(params[:login_attempt])

      if @login_form.valid?
        session[:contact_id] = @login_form.id
        redirect_to market_share_path
      else
        render 'new'
      end
    end
  end
end
