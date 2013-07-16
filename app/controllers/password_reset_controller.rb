class PasswordResetController < ApplicationController
  def new
    @password_reset = PasswordResetForm.new
  end

  def create
    @password_reset = PasswordResetForm.new(params[:password_reset])

    if @password_reset.save
      redirect_to root_path, notice: 'To reset your password, please follow the instructions sent to your email address.'
    else
      render :new
    end
  end
end