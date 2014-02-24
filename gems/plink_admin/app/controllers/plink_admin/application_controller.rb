module PlinkAdmin
  class PlinkAdmin::ApplicationController < ActionController::Base

    layout 'plink_admin/application'

    before_filter :authenticate_admin!

    private

    def after_sign_in_path_for(resource)
      plink_admin.root_path
    end

    def after_sign_out_path_for(resource)
      plink_admin.root_path
    end

  end
end
