class AccountsController < ApplicationController
  include TrackingExtensions
  include AutoLoginExtensions

  before_filter :require_authentication, except: :login_from_email

  def show
    @current_tab = 'account'

    @bank_account = plink_intuit_account_service.find_by_user_id(current_user.id)
    @user_has_account = !!@bank_account
    @currency_activity = plink_currency_activity_service.get_for_user_id(current_user.id).map { |debit_credit| CurrencyActivityPresenter.build_currency_activity(debit_credit) }
  end

  def update
    if plink_user_service.verify_password(current_user.id, params.delete(:password))
      if updating_password?(params)
        plink_user = plink_user_service.update_password(
          current_user.id,
          new_password: params.delete(:new_password),
          new_password_confirmation: params.delete(:new_password_confirmation)
        )
      else
        plink_user = plink_user_service.update(current_user.id, updatable_user_attributes(params))
      end

      if plink_user.valid?
        update_email_in_lyris(current_user.email, params[:email]) if updating_email?(params)
        render json: displayable_user_hash(updatable_user_attributes(params))
      else
        render json: {'error_message' => 'Please correct the following errors and submit the form again:', 'errors' => plink_user.errors.messages}, status: 403
      end
    else
      render json: {'error_message' => 'Please correct the following errors and submit the form again:', 'errors' => {:password_error => ['Current password is incorrect']}}, status: 401
    end
  end

  def login_from_email
    auto_login_user(params[:user_token], account_path(params.except(:controller, :action, :user_token)))
  end

private

  def update_email_in_lyris(old_email, new_email)
    Lyris::UserService.delay.update_users_email(old_email, new_email)
  end

  def displayable_user_hash(attrs)
    attrs[:first_name] = attrs[:first_name][0..UserPresenter::FIRST_NAME_DISPLAY_LENGTH] if attrs[:first_name].present?
    attrs
  end

  def updating_email?(parameters)
    parameters[:email].present? && parameters[:email] != current_user.email
  end

  def updating_password?(parameters)
    parameters[:new_password].present? || parameters[:new_password_confirmation].present?
  end

  def updatable_user_attributes(parameters)
    parameters.slice(:email, :first_name)
  end

  def plink_currency_activity_service
    Plink::CurrencyActivityService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end
end
