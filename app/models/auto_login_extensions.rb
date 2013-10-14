module AutoLoginExtensions
  def auto_login_user(user_token, redirect_path)
    user = AutoLoginService.find_by_user_token(user_token)
    sign_in_user(user) if user.present?

    if current_user.logged_in?
      redirect_to redirect_path
    else
      redirect_to root_url, notice: 'Link expired.'
    end
  end
end

