class Plink::CardLinkUrlGenerator

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def create_url(params)

    return base_url if params[:referrer_id].blank?

    uri = URI.parse(base_url)

    query_params = uri.query.to_s.split("&")
    query_params << "refer=#{params[:referrer_id]}"
    query_params << "aid=#{params[:affiliate_id]}" if params[:affiliate_id].present?
    uri.query = query_params.join("&")

    uri.to_s
  end

  def change_url
    config.card_change_url
  end

  private

  def base_url
    config.card_add_url
  end

end