namespace :reverifications do
  desc 'Inserts pending reverifications based on what errors users have been receiving'
  task insert_reverification_notices: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning reverifications:insert_reverification_notices"

      intuit_account_service = Plink::IntuitAccountService.new
      Plink::UserIntuitErrorRecord.errors_that_require_attention.each do |user_intuit_error|
        StatsD.increment('rake.reverifications.insert_reverification_notice')
        create_reverification(user_intuit_error, intuit_account_service)
      end

      puts "#{Time.zone.now}] Ending reverifications:insert_reverification_notices"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "insert_reverification_notices Rake task failed")
    end
  end

  desc 'looks for unsent reverification notices and sends them'
  task send_reverification_notices: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning reverifications:send_reverification_notices"
      intuit_account_service = Plink::IntuitAccountService.new
      user_service = Plink::UserService.new

      reverifications_requiring_notice.each do |reverification_record|
        send_reverification(reverification_record, user_service, intuit_account_service)
      end
      puts "[#{Time.zone.now}] Ending reverifications:send_reverification_notices"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "send_reverification_notices Rake task failed")
    end
  end

  desc 'Removes accounts from intuit that have not been reverified in 2 weeks'
  task remove_accounts_with_expired_reverifications: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning reverifications:remove_accounts_with_expired_reverifications"
      Plink::UserReverificationRecord.
        incomplete.
        includes(:users_institution_record).
        where('created < ?', 2.weeks.ago).
        each do |user_reverification_record|
          remove_intuit_account(user_reverification_record)
        end
      puts "[#{Time.zone.now}] Ending reverifications:remove_accounts_with_expired_reverifications"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "remove_accounts_with_expired_reverifications Rake task failed")
    end
  end

  desc 'Sets completed_on time for records that have changed status in Intuit'
  task set_status_code_108_to_completed: :environment do
    begin
      stars
      puts "[#{Time.zone.now}] Beginning task to set 108 status codes completed_on"

      reverifications = Plink::UserReverificationRecord.
        select('usersReverifications.*').
        incomplete.
        joins('INNER JOIN usersIntuitErrors ON usersReverifications.usersIntuitErrorID = usersIntuitErrors.usersIntuitErrorID').
        joins('INNER JOIN intuitErrors ON usersIntuitErrors.intuitErrorID = intuitErrors.intuitErrorID').
        where('intuitErrors.intuitErrorID = 108')

      reverifications.each do |reverification|
        process_reverification(reverification)
      end

      puts "[#{Time.zone.now}] Task finished setting completed_on for 108 status codes"
      stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "set_status_code_108_to_completed Rake task failed")
    end
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

  def create_reverification(user_intuit_error, intuit_account_service)
    begin
      intuit_account = intuit_account_service.find_by_user_id(user_intuit_error.user_id)
      user_record = Plink::UserRecord.find_by_id(user_intuit_error.user_id)

      return if intuit_account.blank? || user_record.primary_virtual_currency != plink_points

      if intuit_account.users_institution_id == user_intuit_error.users_institution_id && intuit_account.active?
        Plink::UserReverificationRecord.create(
          intuit_error_id: user_intuit_error.intuit_error_id,
          user_id: user_intuit_error.user_id,
          users_institution_id: user_intuit_error.users_institution_id,
          users_intuit_error_id: user_intuit_error.id
        )
        puts "[#{Time.zone.now}] Inserting reverification for user_id: #{user_intuit_error.user_id}, users_institution_id: #{user_intuit_error.users_institution_id}, intuit_error_id: #{user_intuit_error.intuit_error_id}"
      end
    rescue Exception
      message = "insert_reverification_notices failure for user.id = #{user_intuit_error.user_id}, "
      message << "user_intuit_error.id = #{user_intuit_error.id}"
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end

  def send_reverification(reverification_record, user_service, intuit_account_service)
    begin
      user = user_service.find_by_id(reverification_record.user_id)
      intuit_account = intuit_account_service.find_by_user_id(reverification_record.user_id)
      reverification_presenter = UserReverificationEmailPresenter.new(reverification_record, user, intuit_account)

      if reverification_presenter.can_be_sent?
        mail_params = {
          additional_category_information: reverification_presenter.intuit_error_id,
          email: user.email,
          explanation_message: reverification_presenter.explanation_message,
          first_name: user.first_name,
          html_link_message: reverification_presenter.html_link_message,
          removal_date: reverification_presenter.removal_date,
          text_link_message: reverification_presenter.text_link_message
        }

        ReverificationMailer.delay.notice_email(mail_params)

        Plink::UserReverificationRecord.find(reverification_presenter.id).
          update_attributes(is_notification_successful: true)

        puts "[#{Time.zone.now}] Sending reverification for user_id: #{user.id}, users_reverification_id: #{reverification_record.id}, intuit_error_id, #{reverification_record.intuit_error_id}"
      end
    rescue Exception
      message = "send_reverification_notices failure for user.id = #{reverification_record.user_id}, "
      message << "reverification_record.id = #{reverification_record.id}"
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end

  def remove_intuit_account(user_reverification_record)
    begin
      user_reverification_record.users_institution_record.all_accounts_in_intuit.each do |intuit_account_record|
        StatsD.increment('rake.reverifications.remove_intuit_account')
        Intuit::AccountRemovalService.delay(queue: 'intuit_account_removals').
          remove(
            intuit_account_record.account_id,
            intuit_account_record.user_id,
            intuit_account_record.users_institution_id,
          )
        puts "[#{Time.zone.now}] Removing account_id: #{intuit_account_record.account_id}, user_id: #{intuit_account_record.user_id}, users_institution_id: #{intuit_account_record.users_institution_id}"
      end
    rescue Exception
      message = "remove_accounts_with_expired_reverifications failure for user.id = #{user_reverification_record.user_id}, "
      message << "user_reverification_record.id = #{user_reverification_record.id}"
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end

  def process_reverification(reverification)
    begin
      user_id = reverification.user_id
      intuit_account = Plink::IntuitAccountService.new.find_by_user_id(user_id)

      if intuit_account && !intuit_account.active?
        StatsD.increment('rake.reverifications.process_reverification')
        intuit_response = Intuit::Request.new(user_id).account(intuit_account.account_id)

        response = Intuit::Response.new(intuit_response).parse

        if response[:error]
          puts "[#{Time.zone.now}] ERROR: Could not retrieve data from Intuit. Returned #{response[:value]}"
        elsif response[:aggr_status_codes].include?(108)
          puts "[#{Time.zone.now}] WARNING: Status code 108 still exists for user_id: #{user_id}"
        else
          reverification.update_attributes(completed_on: Time.zone.now)
          puts "[#{Time.zone.now}] SUCCESS: Updated reverification_id: #{reverification.id}"
        end
      end
    rescue Exception
      message = "set_status_code_108_to_completed failure for user.id = #{reverification.user_id}, "
      message << "reverification.id = #{reverification.id}"
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end

  def stars
    puts '*' * 150
  end
end
