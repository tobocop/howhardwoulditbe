class OfferItemPresenter
  attr_reader :offer, :virtual_currency, :view_context, :linked, :signed_in

  def initialize(offer, options={})
    @offer = offer
    @virtual_currency = options.fetch(:virtual_currency)
    @view_context = options.fetch(:view_context)
    @linked = options.fetch(:linked)
    @signed_in = options.fetch(:signed_in)
  end

  def id
    offer.id
  end

  def name
    offer.name.to_s
  end

  def dom_id
    "offer_#{offer.id}"
  end

  def modal_dom_id
    "offer-details-#{offer.id}"
  end

  def image_url
    Plink::RemoteImagePath.url_for(offer.image_url)
  end

  def image_description
    name
  end

  def max_award_amount
    virtual_currency.amount_in_currency(offer.max_dollar_award_amount)
  end

  def currency_name
    virtual_currency.currency_name
  end

  def tier_descriptions
    offer.tiers_by_minimum_purchase_amount.map do |tier|
      "Spend #{view_context.number_to_currency(tier.minimum_purchase_amount)} or more, get #{virtual_currency.amount_in_currency(tier.dollar_award_amount)} #{virtual_currency.currency_name}."
    end
  end

  def call_to_action_link
    if linked
      view_context.link_to('Add To My Wallet',
                           view_context.wallet_offers_path(offer_id: offer.id),
                           class: 'button primary-action narrow',
                           data: {add_to_wallet: true, offer_dom_selector: "##{dom_id}"})
    elsif signed_in
      view_context.link_to("Link Your Card",
                           view_context.account_path(link_card: true),
                           class: 'button primary-action narrow')
    else
      view_context.link_to("Join Plink Today",
                           view_context.root_path(sign_up: true),
                           class: 'button primary-action narrow')
    end
  end

  def description
    Plink::StringSubstituter.gsub(offer.detail_text, offer.minimum_purchase_amount_tier, virtual_currency)
  end

  def as_json(options={})
    {
      id: id,
      name: name,
      dom_id: dom_id,
      modal_dom_id: modal_dom_id,
      image_url: image_url,
      image_description: image_description,
      max_award_amount: max_award_amount,
      currency_name: currency_name,
      description: description,
      tier_descriptions: tier_descriptions,
      call_to_action_link: call_to_action_link
    }
  end
end