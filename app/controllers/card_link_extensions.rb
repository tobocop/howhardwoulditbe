module CardLinkExtensions
  def plink_card_link_url_generator
    Plink::CardLinkUrlGenerator.new(Plink::Config.instance)
  end

  def card_link_referral_params
    { referrer_id: session[:referrer_id], affiliate_id: session[:affiliate_id] }
  end
end

