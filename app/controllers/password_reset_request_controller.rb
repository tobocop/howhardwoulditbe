class PasswordResetRequestController < ApplicationController
  layout 'plain'

  def new
    @password_reset = PasswordResetRequestForm.new
  end

  def create
    @password_reset = PasswordResetRequestForm.new(params[:password_reset])

    if @password_reset.save
      redirect_to root_path, notice: 'To reset your password, please follow the instructions sent to your email address.'
    else
      render :new
    end
  end
end