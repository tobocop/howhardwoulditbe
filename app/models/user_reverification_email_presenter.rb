class UserReverificationEmailPresenter
  attr_accessor :intuit_account, :user, :user_reverification_record

  def initialize(user_reverification_record, user, intuit_account)
    @intuit_account = intuit_account
    @user = user
    @user_reverification_record = user_reverification_record
  end

  delegate :id, :intuit_error_id, :link, :notice_type, to: :user_reverification_record

  def can_be_sent?
    user.can_receive_plink_email? && !intuit_account.active?
  end

  def explanation_message
    I18n.t(translation_key + '.explanation_message')
  end

  def html_link_message
    I18n.t(translation_key + '.html_link_message',
      institution_name: intuit_account.bank_name,
      reverification_link: reverification_link
    )
  end

  def text_link_message
    I18n.t(translation_key + '.text_link_message',
      institution_name: intuit_account.bank_name,
      reverification_link: reverification_link
    )
  end

private

  def translation_key
    'application.intuit_error_messages.emails.' + notice_type + '.error_' + intuit_error_id.to_s
  end

  def reverification_link
    link.nil? ? users_account_url : link
  end

  def users_account_url
    Rails.application.routes.url_helpers.login_from_email_account_url(user_token: user_token, link_card: true)
  end

  def user_token
    AutoLoginService.generate_token(user.id)
  end
end

