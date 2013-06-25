class AccountsController < ApplicationController
  def show
    @current_tab = 'account'
    @user_has_account = ActiveIntuitAccount.user_has_account?(current_user.id)
  end
end
