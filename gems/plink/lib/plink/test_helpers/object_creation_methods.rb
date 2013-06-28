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
          start_date: Date.yesterday,
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

    def new_user(orig_options = {})
      options = orig_options.dup

      plaintext_password = options.delete(:password)
      if plaintext_password.present?
        password = Password.new(unhashed_password: plaintext_password)
        options[:password_hash] = password.hashed_value
        options[:salt] = password.salt
      end


      defaults = {
          email: 'test@example.com',
          first_name: 'Joe',
          password_hash: 'D7913D231B862AEAD93FADAFB90A90E1A599F0FC08851414FD69C473242DAABD4E6DBD978FBEC1B33995CD2DA58DD1FEA660369E6AE962007162721E9C195192', # password: AplaiNTextstrIng55
          salt: '6BA943B9-E9E3-8E84-4EDCA75EE2ABA2A5'
      }

      User.new(defaults.merge(options))
    end

    def create_user(options = {})
      user = new_user(options)
      user.save!
      user
    end

    def new_virtual_currency(options = {})
      defaults = {
          name: 'Plink points',
          subdomain: VirtualCurrency::DEFAULT_SUBDOMAIN,
          exchange_rate: 100,
          site_name: 'Plink',
          singular_name: 'Plink point'
      }

      VirtualCurrency.new(defaults.merge(options))
    end

    def create_virtual_currency(options = {})
      virtual_currency = new_virtual_currency(options)
      virtual_currency.save!
      virtual_currency
    end

    def apply(object, defaults, overrides)
      options = defaults.merge(overrides)
      options.each do |method, value_or_proc|
        object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
      end
    end
  end
end