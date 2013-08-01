PlinkAdmin.impersonation_redirect_url = '/wallet'

PlinkAdmin.sign_in_user = ->(user_id, session) do
  session[:current_user_id] = user_id
end
