module WalletItemPresenter
  class PopulatedWalletItemPresenter < BaseWalletItemPresenter
    attr_reader :wallet_item, :virtual_currency, :view_context

    def initialize(wallet_item, options = {})
      @wallet_item = wallet_item
      @virtual_currency = options.fetch(:virtual_currency)
      @view_context = options.fetch(:view_context)
    end

    def partial
      template_name
    end

    def template_name
      'populated_wallet_item'
    end

    def special_offer_type
      if wallet_item.offer.is_new
        'ribbon-new-offer'
      elsif wallet_item.offer.is_promotion
        'ribbon-promo-offer'
      end
    end

    def special_offer_type_text
      if wallet_item.offer.is_new
        'New Partner!'
      elsif wallet_item.offer.is_promotion
        'Get double points when you make a qualifying purchase at this partner.'
      end
    end

    def icon_url
      Plink::RemoteImagePath.url_for(wallet_item.offer.image_url)
    end

    def icon_description
      wallet_item.offer.name
    end

    def max_currency_award_amount
      virtual_currency.amount_in_currency(wallet_item.offer.max_dollar_award_amount)
    end

    def currency_name
      virtual_currency.currency_name
    end

    def offer_id
      wallet_item.offer.id
    end

    def wallet_offer_url
      view_context.wallet_offer_url(offer_id)
    end

    def as_json(options={})
      {
        template_name: template_name,
        special_offer_type: special_offer_type,
        special_offer_type_text: special_offer_type_text,
        icon_url: icon_url,
        icon_description: icon_description,
        currency_name: currency_name,
        max_currency_award_amount: max_currency_award_amount,
        wallet_offer_url: wallet_offer_url
      }
    end
  end
end