namespace :reverifications do
  desc 'Inserts pending reverifications based on what errors users have been receiving'
  task insert_reverification_notices: :environment do
    stars; puts "[#{Time.zone.now}] Beginning reverifications:insert_reverification_notices"

    intuit_account_service = Plink::IntuitAccountService.new
    Plink::UserIntuitErrorRecord.errors_that_require_attention.each do |user_intuit_error|
      intuit_account = intuit_account_service.find_by_user_id(user_intuit_error.user_id)
      user_record = Plink::UserRecord.find_by_id(user_intuit_error.user_id)

      next if intuit_account.blank? || user_record.primary_virtual_currency != plink_points

      if intuit_account.users_institution_id == user_intuit_error.users_institution_id && intuit_account.active?
        Plink::UserReverificationRecord.create(
          intuit_error_id: user_intuit_error.intuit_error_id,
          user_id: user_intuit_error.user_id,
          users_institution_id: user_intuit_error.users_institution_id,
          users_intuit_error_id: user_intuit_error.id
        )
        puts "[#{Time.zone.now}] Inserting reverification for user_id: #{user_intuit_error.user_id}, users_institution_id: #{user_intuit_error.users_institution_id}, intuit_error_id: #{user_intuit_error.intuit_error_id}"
      end
    end

    puts "#{Time.zone.now}] Ending reverifications:insert_reverification_notices"; stars
  end

  desc 'looks for unsent reverification notices and sends them'
  task send_reverification_notices: :environment do
    stars; puts "[#{Time.zone.now}] Beginning reverifications:send_reverification_notices"
    intuit_account_service = Plink::IntuitAccountService.new
    user_service = Plink::UserService.new

    reverifications_requiring_notice.each do |reverification_record|
      user = user_service.find_by_id(reverification_record.user_id)
      intuit_account = intuit_account_service.find_by_user_id(reverification_record.user_id)
      reverification_presenter = UserReverificationEmailPresenter.new(reverification_record, user, intuit_account)

      if reverification_presenter.can_be_sent?
        mail_params = {
          email: user.email,
          first_name: user.first_name,
          explanation_message: reverification_presenter.explanation_message,
          html_link_message: reverification_presenter.html_link_message,
          text_link_message: reverification_presenter.text_link_message
        }

        ReverificationMailer.delay.notice_email(mail_params)

        Plink::UserReverificationRecord.find(reverification_presenter.id).
          update_attributes(is_notification_successful: true)

        puts "[#{Time.zone.now}] Sending reverification for user_id: #{user.id}, users_reverification_id: #{reverification_record.id}, intuit_error_id, #{reverification_record.intuit_error_id}"
      end
    end
    puts "[#{Time.zone.now}] Ending reverifications:send_reverification_notices"; stars
  end

  desc 'Removes accounts from intuit that have not been reverified in 2 weeks'
  task remove_accounts_with_expired_reverifications: :environment do
    stars; puts "[#{Time.zone.now}] Beginning reverifications:remove_accounts_with_expired_reverifications"
    Plink::UserReverificationRecord.
      incomplete.
      includes(:users_institution_record).
      where('created < ?', 2.weeks.ago).
    each do |user_reverification_record|
      user_reverification_record.users_institution_record.all_accounts_in_intuit.each do |intuit_account_record|
        Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').
          remove(
            intuit_account_record.account_id,
            intuit_account_record.user_id,
            intuit_account_record.users_institution_id,
          )
        puts "[#{Time.zone.now}] Removing account_id: #{intuit_account_record.account_id}, user_id: #{intuit_account_record.user_id}, users_institution_id: #{intuit_account_record.users_institution_id}"
      end
    end
    puts "[#{Time.zone.now}] Ending reverifications:remove_accounts_with_expired_reverifications"; stars
  end

private

  def plink_points
    Plink::VirtualCurrency.default
  end

  def reverifications_requiring_notice
    Plink::UserReverificationRecord.
      requiring_notice.
      joins(:user_record)
  end

  def stars
    puts '*' * 150
  end
end
