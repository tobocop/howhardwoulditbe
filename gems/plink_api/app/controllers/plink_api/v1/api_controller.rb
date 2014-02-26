module PlinkApi::V1
  class ApiController < PlinkApi::ApplicationController
    respond_to :json

    def home
      respond_with 'api'
    end
  end
end
