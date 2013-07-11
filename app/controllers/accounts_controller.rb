class AccountsController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'account'
    @card_link_url = Plink::CardLinkUrlGenerator.create_url(referrer_id: session[:referrer_id], affiliate_id: session[:affiliate_id])
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @currency_activity = plink_currency_activity_service.get_for_user_id(current_user.id).map {|debit_credit| CurrencyActivityPresenter.build_currency_activity(debit_credit)}
  end

  private

  def plink_currency_activity_service
    Plink::CurrencyActivityService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end
end
