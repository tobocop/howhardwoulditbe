namespace :redemptions do
  desc 'Checks to see if our tango redemptions have gone over the limit for the day'
  task check_daily_limit: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Starting redemptions:check_daily_limit"

      if Plink::TangoLimitService.past_daily_limit?
        puts "[#{Time.zone.now}] Tango Limit reached"

        Plink::TangoRedemptionShutoffService.halt_redemptions
        AllPlinkNotificationMailer.tango_over_daily_limit.deliver
      end

      puts "[#{Time.zone.now}] Ending redemptions:check_daily_limit"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "redemptions:check_daily_limit Rake task failed. CHECK IMMEDIATELY")
    end
  end

private

  def stars
    puts '*' * 150
  end
end
