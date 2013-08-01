require 'devise'
require 'haml-rails'

module PlinkAdmin
  require 'plink_admin/engine'

  mattr_accessor :impersonation_redirect_url, :sign_in_user, :sign_out_user
end
