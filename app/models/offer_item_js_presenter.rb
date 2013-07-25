class OfferItemJsPresenter
  attr_reader :virtual_currency

  def initialize(options={})
    @virtual_currency = options.fetch(:virtual_currency)
  end

  def id
    '{{id}}'
  end

  def name
    '{{name}}'
  end

  def dom_id
    "{{dom_id}}"
  end

  def modal_dom_id
    "{{modal_dom_id}}"
  end

  def special_offer_type
    '{{special_offer_type}}'
  end

  def special_offer_type_text
    '{{special_offer_type_text}}'
  end

  def image_url
    "{{image_url}}"
  end

  def image_description
    "{{image_description}}"
  end

  def max_award_amount
    "{{max_award_amount}}"
  end

  def currency_name
    "{{currency_name}}"
  end

  def call_to_action_link
    "{{{call_to_action_link}}}"
  end

  def description
    "{{{description}}}"
  end
end