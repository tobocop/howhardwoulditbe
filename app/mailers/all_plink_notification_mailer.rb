class AllPlinkNotificationMailer < PlinkMailer
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def tango_over_daily_limit
    mail(
      to: 'peeps@plink.com',
      subject: 'ALERT:: Tango redemptions have exceeded $2500'
    )
  end
end
