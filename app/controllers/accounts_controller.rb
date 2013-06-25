class AccountsController < ApplicationController
  def show
    @current_tab = 'account'
    @user_has_account = ActiveIntuitAccount.user_has_account?(current_user.id)
    @card_link_url = Plink::CardLinkUrlGenerator.create_url(referrer_id: session[:referrer_id], affiliate_id: session[:affiliate_id])
  end
end
