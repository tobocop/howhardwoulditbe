class SessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(email: params[:user_session][:email], password: params[:user_session][:password])

    if @user_session.valid?
      sign_in_user(@user_session.user)
      redirect_to dashboard_path
    else
      render :new
    end
  end
end