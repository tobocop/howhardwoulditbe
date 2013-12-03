class ErrorsController < ApplicationController
  def general_error
    render :status => 500, :formats => [:html]
  end

  def not_found
    render :status => 404, :formats => [:html]
  end
end
