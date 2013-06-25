class Plink::CardLinkUrlGenerator

  def self.create_url(params)

    return base_url if params[:referrer_id].blank?

    uri = URI.parse(base_url)

    query_params = uri.query.to_s.split("&")
    query_params << "refer=#{params[:referrer_id]}"
    query_params << "aid=#{params[:affiliate_id]}" if params[:affiliate_id].present?
    uri.query = query_params.join("&")

    uri.to_s
  end

  def self.base_url
    Rails.application.config.coldfusion_card_add_url
  end

end