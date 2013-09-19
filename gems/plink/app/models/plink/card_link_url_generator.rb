class Plink::CardLinkUrlGenerator

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def create_url(params)

    return base_url if params.length == 0

    uri = URI.parse(base_url)

    query_params = uri.query.to_s.split("&")
    query_params << "refer=#{params[:referrer_id]}" if params[:referrer_id].present?
    query_params << "aid=#{params[:affiliate_id]}" if params[:affiliate_id].present?
    query_params << "subID2=#{params[:sub_id_two]}" if params[:sub_id_two].present?

    uri.query = query_params.join("&")

    uri.to_s
  end

  def change_url
    config.card_change_url
  end

  def card_reverify_url
     config.card_reverify_url
  end

  private

  def base_url
    config.card_add_url
  end

end
