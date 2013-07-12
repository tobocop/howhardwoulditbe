class AccountsController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'account'
    @card_link_url = plink_card_link_url_generator.create_url(referrer_id: session[:referrer_id], affiliate_id: session[:affiliate_id])
    @card_change_url = plink_card_link_url_generator.change_url
    @bank_account = plink_intuit_account_service.find_by_user_id(current_user.id)
    @user_has_account = !!@bank_account
    @currency_activity = plink_currency_activity_service.get_for_user_id(current_user.id).map {|debit_credit| CurrencyActivityPresenter.build_currency_activity(debit_credit)}
  end

  private

  def plink_currency_activity_service
    Plink::CurrencyActivityService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end

  def plink_card_link_url_generator
    Plink::CardLinkUrlGenerator.new(Plink::Config.instance)
  end
end
