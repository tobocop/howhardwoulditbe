StatsD.server = 'localhost:8125'
StatsD.logger = Rails.logger
StatsD.mode = Rails.env.to_sym # only sends when :production
StatsD.prefix = Rails.application.class.parent_name
StatsD.default_sample_rate = 0.1 # Sample 10% of events. By default all events are reported.

Intuit::Request.extend StatsD::Instrument
Intuit::Request.statsd_measure :accounts, 'intuit.request.accounts'
Intuit::Request.statsd_measure :account, 'intuit.request.account'
Intuit::Request.statsd_measure :respond_to_mfa, 'intuit.request.respond_to_mfa'
Intuit::Request.statsd_measure :update_credentials, 'intuit.request.update_credentials'
Intuit::Request.statsd_measure :update_mfa, 'intuit.request.update_mfa'
Intuit::Request.statsd_measure :login_accounts, 'intuit.request.login_accounts'
Intuit::Request.statsd_measure :institution_data, 'intuit.request.institution_data'
Intuit::Request.statsd_measure :update_account_type, 'intuit.request.update_account_type'
Intuit::Request.statsd_measure :get_transactions, 'intuit.request.get_transactions'

HomeController.extend StatsD::Instrument
HomeController.statsd_count_success :index, 'home.index'

GigyaLoginHandlerController.extend StatsD::Instrument
GigyaLoginHandlerController.statsd_measure :create, 'gigya_login_handler.create'

RegistrationsController.extend StatsD::Instrument
RegistrationsController.statsd_measure :create, 'registrations_controller.create'

Plink::UserCreationService.extend StatsD::Instrument
Plink::UserCreationService.statsd_measure :create_user, 'user_creation_service.create_user'
Plink::UserCreationService.statsd_count_success :create_user, 'user_creation_service.create_user'

GigyaSocialLoginService.extend StatsD::Instrument
GigyaSocialLoginService.statsd_measure :sign_in_user, 'gigya_social_login_service.sign_in_user'
GigyaSocialLoginService.statsd_count_success :sign_in_user, 'gigya_social_login_service.sign_in_user'

BonusNotificationMailer.extend StatsD::Instrument
BonusNotificationMailer.statsd_count_success :out_of_wallet_transaction_email, 'bonus_notification_mailer.out_of_wallet_transaction_email'
BonusNotificationMailer.statsd_count_success :out_of_wallet_transaction_reminder_email, 'bonus_notification_mailer.out_of_wallet_transaction_reminder_email'

ContactMailer.extend StatsD::Instrument
ContactMailer.statsd_count_success :contact_email, 'contact_mailer.contact_email'

ContestMailer.extend StatsD::Instrument
ContestMailer.statsd_count_success :daily_reminder_email, 'contest_mailer.daily_reminder_email'
ContestMailer.statsd_count_success :three_day_reminder_email, 'contest_mailer.three_day_reminder_email'
ContestMailer.statsd_count_success :winner_email, 'contest_mailer.winner_email'

OfferExpirationMailer.extend StatsD::Instrument
OfferExpirationMailer.statsd_count_success :offer_removed_email, 'offer_expiration_mailer.offer_removed_email'
OfferExpirationMailer.statsd_count_success :offer_expiring_soon_email, 'offer_expiration_mailer.offer_expiring_soon_email'

PasswordResetMailer.extend StatsD::Instrument
PasswordResetMailer.statsd_count_success :instructions, 'password_reset_mailer.instructions'

PromotionalWalletItemMailer.extend StatsD::Instrument
PromotionalWalletItemMailer.statsd_count_success :unlock_promotional_wallet_item_email, 'promotional_wallet_item_mailer.unlock_promotional_wallet_item_email'

ReverificationMailer.extend StatsD::Instrument
ReverificationMailer.statsd_count_success :notice_email, 'reverification_mailer.notice_email'

RewardMailer.extend StatsD::Instrument
RewardMailer.statsd_count_success :reward_notification_email, 'reward_mailer.reward_notification_email'

UserRegistrationMailer.extend StatsD::Instrument
UserRegistrationMailer.statsd_count_success :welcome, 'user_registration_mailer.welcome'
UserRegistrationMailer.statsd_count_success :complete_registration, 'user_registration_mailer.complete_registration'
