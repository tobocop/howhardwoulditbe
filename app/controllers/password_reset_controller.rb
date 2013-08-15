class PasswordResetController < ApplicationController
  def new
    @password_reset = PasswordResetForm.new(token: params[:token])
  end

  def create
    @password_reset = PasswordResetForm.new(params[:password_reset])

    if @password_reset.save
      redirect_to root_path, notice: "Your password has been successfully updated. Please sign in."
    else
      render 'new'
    end
  end
end
