module Plink
  module ObjectCreationMethods

    def new_offer(options = {})
      defaults = {
          advertiser_id: 0,
          advertisers_rev_share: 0,
          detail_text: 'awesome text',
          start_date: '1900-01-01'
      }

      Plink::OfferRecord.new { |offer| apply(offer, defaults, options) }
    end

    def create_offer(options = {})
      new_offer(options).tap(&:save!)
    end

    def new_offers_virtual_currency(options = {})
      defaults = {
          offer_id: 143,
          virtual_currency_id: 34
      }

      Plink::OffersVirtualCurrencyRecord.new { |ovc| apply(ovc, defaults, options) }
    end

    def create_offers_virtual_currency(options = {})
      new_offers_virtual_currency(options).tap(&:save!)
    end

    def new_tier(options = {})
      defaults= {
          begin_date: Date.yesterday,
          end_date: Date.tomorrow,
          dollar_award_amount: 100,
          minimum_purchase_amount: 199,
          offers_virtual_currency_id: 2
      }

      Plink::TierRecord.new { |tier| apply(tier, defaults, options) }
    end

    def create_tier(options = {})
      new_tier(options).tap(&:save!)
    end

    def new_advertiser(options = {})
      defaults = {
          advertiser_name: 'Old Nervy'
      }

      AdvertiserRecord.new { |advertiser| apply(advertiser, defaults, options) }
    end

    def create_advertiser(options = {})
      new_advertiser(options).tap(&:save!)
    end

    def apply(object, defaults, overrides)
      options = defaults.merge(overrides)
      options.each do |method, value_or_proc|
        object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
      end
    end
  end
end