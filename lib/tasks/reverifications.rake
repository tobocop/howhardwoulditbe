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

    reverifications_requiring_notice.each do |reverification|
      user = user_service.find_by_id(reverification.user_id)
      intuit_account = intuit_account_service.find_by_user_id(reverification.user_id)

      if user.can_receive_plink_email? && !intuit_account.active?
        mail_params = {
          email: user.email,
          first_name: user.first_name,
          institution_name: intuit_account.bank_name,
          intuit_error_id: reverification.intuit_error_id,
          notice_type: reverification.notice_type,
          reverification_link: reverification.link,
          user_token: AutoLoginService.generate_token(user.id)
        }
        ReverificationMailer.delay.notice_email(mail_params)

        Plink::UserReverificationRecord.find(reverification.id).
          update_attributes(is_notification_successful: true)

        puts "[#{Time.zone.now}] Sending reverification for user_id: #{user.id}, users_reverification_id: #{reverification.id}, intuit_error_id, #{reverification.intuit_error_id}"
      end
    end
    puts "[#{Time.zone.now}] Ending reverifications:send_reverification_notices"; stars
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
