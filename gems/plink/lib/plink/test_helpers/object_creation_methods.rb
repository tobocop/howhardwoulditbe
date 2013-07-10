module Plink
  module ObjectCreationMethods

    def new_award_type(options = {})
      defaults = {
          award_code: 'ASD',
          award_display_name: 'Awesome Award',
          award_type: 'cool',
          is_active: true
      }

      Plink::AwardType.new {|award_type| apply(award_type, defaults, options)}
    end

    def create_award_type(options = {})
      new_award_type(options).tap(&:save!)
    end

    def new_free_award(options = {})
      defaults = {
          award_type_id: 1,
          currency_award_amount: 100,
          dollar_award_amount: 1,
          user_id: 1,
          is_active: true,
          users_virtual_currency_id: 1,
          virtual_currency_id: 1,
          is_successful: true,
          is_notification_successful: true
      }

      Plink::FreeAward.new {|free_award| apply(free_award, defaults, options)}
    end

    def create_free_award(options = {})
      new_free_award(options).tap(&:save!)
    end

    def new_oauth_token(options = {})
      defaults = {
          encrypted_oauth_token: 'derp',
          encrypted_oauth_token_secret: 'derp_secret',
          oauth_token_iv: 'derp_iv',
          oauth_token_secret_iv: 'derp_secret_iv',
          user_id: 1,
          is_active: true
      }
      Plink::OauthToken.new { |oauth_token| apply(oauth_token, defaults, options) }
    end

    def create_oauth_token(options = {})
      new_oauth_token(options).tap(&:save!)
    end

    def new_users_institution_account(options = {})
      defaults = {
          account_id: 1,
          begin_date: Date.yesterday,
          end_date: '2999-12-31',
          user_id: 24,
          users_institution_account_staging_id: 0,
          users_institution_id: 0,
          is_active: true,
          in_intuit: true
      }
      Plink::UsersInstitutionAccount.new { |uia| apply(uia, defaults, options) }
    end

    def create_users_institution_account(options = {})
      new_users_institution_account(options).tap(&:save!)
    end

    def new_reward_amount(options = {})
      defaults = {
          dollar_award_amount: 143,
          is_active: true
      }
      Plink::RewardAmountRecord.new { |amount| apply(amount, defaults, options) }
    end

    def create_reward_amount(options = {})
      new_reward_amount(options).tap(&:save!)
    end

    def new_reward(options = {})
      defaults = {
          award_code: 'wolfmart-card',
          name: 'wolfmart',
          is_tango:false
      }

      Plink::RewardRecord.new { |reward| apply(reward, defaults, options) }
    end

    def create_reward(options = {})
      new_reward(options).tap(&:save!)
    end

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

    def create_open_wallet_item(options = {})
      wallet_item = new_open_wallet_item(options)
      wallet_item.save!
      wallet_item
    end

    def new_open_wallet_item(options = {})
      defaults = {
          wallet_id: 1,
          wallet_slot_id: 1,
          wallet_slot_type_id: 1
      }

      OpenWalletItemRecord.new(defaults.merge(options))
    end

    def create_locked_wallet_item(options = {})
      wallet_item = new_locked_wallet_item(options)
      wallet_item.save!
      wallet_item
    end

    def new_locked_wallet_item(options = {})
      defaults = {
        wallet_id: 1,
        wallet_slot_id: 1,
        wallet_slot_type_id: 1
      }

      LockedWalletItemRecord.new(defaults.merge(options))
    end


    def create_populated_wallet_item(options = {})
      wallet_item = new_populated_wallet_item(options)
      wallet_item.save!
      wallet_item
    end

    def new_populated_wallet_item(options = {})
      defaults = {
        wallet_id: 1,
        wallet_slot_id: 1,
        wallet_slot_type_id: 1
      }

      PopulatedWalletItemRecord.new(defaults.merge(options))
    end


    def create_wallet(options = {})
      wallet = new_wallet(options)
      wallet.save!
      wallet
    end

    def new_wallet(options = {})
      defaults = {
          user_id: 1
      }

      WalletRecord.new(defaults.merge(options))
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