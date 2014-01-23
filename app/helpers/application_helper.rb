module ApplicationHelper
  def class_for_nav_tab(current_tab, tab)
    current_tab == tab ? 'selected' : ''
  end

  def plink_currency_format(amount)
    amount = number_to_currency(amount)

    if amount.match /\.00/
      amount[0..amount.index('.')-1]
    else
      amount
    end
  end

  def email_capture_pixel
    session.delete(:email_capture_pixel)
  end

  def redemption_confirmation_text(amount, reward_name)
    "You're about to redeem #{amount.currency_award_amount} #{amount.currency_name} "\
    "for a #{plink_currency_format(amount.dollar_award_amount)} #{reward_name} Gift Card."\
    .html_safe
  end

  def contact_us_message
    "Need help? Please #{link_to 'contact us', contact_path, class: 'text-link'}.".html_safe
  end

  def google_analytics_script_tag
    begin_tag = "<script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');"
    end_tag = "ga('require', 'linkid', 'linkid.js'); ga('send', 'pageview');</script>"

    result =
      case Rails.env
      when 'production'
        begin_tag + "ga('create', 'UA-27582334-2', 'plink.com');" + end_tag
      when 'review'
        begin_tag + "ga('create', 'UA-27582334-3', 'plink-qa.com');" + end_tag
      else
        ''
      end

    result.html_safe
  end

  def flash_error_icon(message)
    haml = "%img{src: '/assets/icon_alert_pink.png', alt: '#{message}', "\
      "class: 'status-img'}"
    Haml::Engine.new(haml).render
  end

  def refer_a_friend_data
    base = 'application.referral.'

    {
      'title' => I18n.t(base + 'title'),
      'description' => I18n.t(base + 'description'),
      'image' => I18n.t(base + 'image'),
      'share-widget' => true
    }
  end
end
