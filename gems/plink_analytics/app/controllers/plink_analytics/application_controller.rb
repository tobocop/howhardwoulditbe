module PlinkAnalytics
  class ApplicationController < ActionController::Base
    helper_method :current_user

    def current_user
      @current_user ||= Plink::ContactRecord.find(session[:contact_id]) if session[:contact_id]
    end
  end
end
