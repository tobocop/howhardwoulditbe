module Plink
  module ObjectCreationMethods
    require 'ostruct'

    def new_news_article(options = {})
      defaults = {
        source: 'TechCrunch',
        source_link: 'http://techcrunch.com/plink',
        published_on: Time.zone.today,
        title: 'the news',
        is_active: true
      }

      Plink::NewsArticleRecord.new { |news_article| apply(news_article, defaults, options) }
    end

    def create_news_article(options = {})
      new_news_article(options).tap(&:save!)
    end

    def new_landing_page(options = {})
      defaults = {
        name: 'My Landing Page',
        partial_path: '/_hereitis.html.haml'
      }

      Plink::LandingPageRecord.new { |landing_page| apply(landing_page, defaults, options) }
    end

    def create_landing_page(options = {})
      new_landing_page(options).tap(&:save!)
    end

    def new_campaign(options = {})
      defaults = {
        name: 'Campaign Name',
        media_type: 'My type',
        creative: 'A creative description',
        is_incent: false,
        start_date: 1.day.ago,
        end_date: 1.day.from_now,
        campaign_hash: 'DERP'
      }

      Plink::CampaignRecord.new { |campaign| apply(campaign, defaults, options) }
    end

    def create_campaign(options = {})
      new_campaign(options).tap(&:save!)
    end

    def new_affiliate(options = {})
      defaults = {
        name: 'Created name',
        has_incented_card_registration: false,
        card_registration_dollar_award_amount: 1.34,
        has_incented_join: false,
        join_dollar_award_amount: 1.34,
        card_add_pixel: '<img src="http://example.com/image.png />',
        email_add_pixel: '<img src="http://example.com/image.png />',
        disclaimer_text: 'some disclaimer stuff'
      }

      Plink::AffiliateRecord.new { |affiliate| apply(affiliate, defaults, options) }
    end

    def create_affiliate(options = {})
      new_affiliate(options).tap(&:save!)
    end

    def new_event_type(options = {})
      defaults = {
        name: 'EVENTTYPEDEFAULT'
      }

      Plink::EventTypeRecord.new { |event_type| apply(event_type, defaults, options) }
    end

    def create_event_type(options = {})
      new_event_type(options).tap(&:save!)
    end

    def new_award_type(options = {})
      defaults = {
        award_code: 'ASD',
        award_display_name: 'Awesome Award',
        award_type: 'cool',
        is_active: true
      }

      Plink::AwardTypeRecord.new { |award_type| apply(award_type, defaults, options) }
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

      Plink::FreeAwardRecord.new { |free_award| apply(free_award, defaults, options) }
    end

    def create_institution(options = {})
      new_institution(options).tap(&:save!)
    end

    def new_institution(options = {})
      defaults = {
        hash_value: 'val',
        name: 'freds',
        intuit_institution_id: 3
      }

      Plink::InstitutionRecord.new { |institution| apply(institution, defaults, options) }
    end

    def create_user_reverification(options = {})
      new_user_reverification(options).tap(&:save!)
    end

    def new_user_reverification(options = {})
      defaults = {
        user_id: 1,
        users_institution_id: 1,
        users_intuit_error_id: 1
      }

      Plink::UserReverificationRecord.new { |reverification| apply(reverification, defaults, options) }
    end

    def new_hero_promotion(options ={})
      defaults = {
        image_url: '/assets/test_image_tbd.jpg',
        name: 'promotion name',
        title: 'Awesome Title',
        display_order: 1,
        is_active: true
      }
      Plink::HeroPromotionRecord.new { |promotion| apply(promotion, defaults, options) }
    end

    def create_hero_promotion(options ={})
      new_hero_promotion(options).tap(&:save!)
    end

    def create_users_institution(options = {})
      new_users_institution(options).tap(&:save!)
    end

    def new_users_institution(options = {})
      defaults = {
        institution_id: 3,
        intuit_institution_login_id: 23,
        hash_check: 'my unique hash',
        user_id: 3
      }

      Plink::UsersInstitutionRecord.new { |ui| apply(ui, defaults, options) }
    end

    def create_free_award(options = {})
      new_free_award(options).tap(&:save!)
    end

    def new_qualifying_award(options = {})
      defaults = {
        currency_award_amount: 13,
        dollar_award_amount: 0.13,
        user_id: 13,
        users_virtual_currency_id: 2,
        virtual_currency_id: 2,
        is_successful: true,
        is_notification_successful: true
      }

      Plink::QualifyingAwardRecord.new { |award| apply(award, defaults, options) }
    end

    def create_qualifying_award(options = {})
      new_qualifying_award(options).tap(&:save!)
    end

    def new_non_qualifying_award(options = {})
      defaults = {
        currency_award_amount: 13,
        dollar_award_amount: 0.13,
        user_id: 13,
        users_virtual_currency_id: 2,
        virtual_currency_id: 2,
        is_successful: true,
        is_notification_successful: true
      }

      Plink::NonQualifyingAwardRecord.new { |award| apply(award, defaults, options) }
    end

    def create_non_qualifying_award(options = {})
      new_non_qualifying_award(options).tap(&:save!)
    end

    def create_redemption(options = {})
      new_redemption(options).tap(&:save!)
    end

    def new_redemption(options = {})
      defaults = {
        dollar_award_amount: 2.3,
        reward_id: 1,
        user_id: 1,
        is_pending: true,
        is_active: true,
        sent_on: nil
      }
      Plink::RedemptionRecord.new { |redemption| apply(redemption, defaults, options) }
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
        begin_date: 1.day.ago,
        end_date: '2999-12-31',
        user_id: 24,
        users_institution_account_staging_id: 0,
        users_institution_id: 0,
        is_active: true,
        in_intuit: true
      }

      Plink::UsersInstitutionAccountRecord.new { |uia| apply(uia, defaults, options) }
    end

    def create_users_institution_account(options = {})
      new_users_institution_account(options).tap(&:save!)
    end

    def new_reward_amount(options = {})
      defaults = {
        reward_id: 1,
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
        is_tango: false,
        description: 'howl at the moon',
        logo_url: '/assets/test/amazon.png'
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
        start_date: 1.day.ago,
        end_date: 1.day.from_now,
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
        salt: '6BA943B9-E9E3-8E84-4EDCA75EE2ABA2A5',
        is_subscribed: true,
        provider: 'organic',
        hold_redemptions: nil,
        ip: '127.0.0.1',
        daily_contest_reminder: nil
      }

      Plink::UserRecord.new { |user| apply(user, defaults, options) }
    end

    def create_user(options = {})
      new_user(options).tap(&:save!)
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

    def new_users_virtual_currency(options = {})
      defaults = {
        start_date: '1900-01-01',
        user_id: 1,
        virtual_currency_id: 2
      }
      UsersVirtualCurrencyRecord.new { |uvc| apply(uvc, defaults, options) }
    end

    def create_users_virtual_currency(options = {})
      new_users_virtual_currency(options).tap(&:save!)
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
        wallet_slot_type_id: 1,
        unlock_reason: 'join'
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
        wallet_slot_type_id: 1,
        unlock_reason: nil
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

    def create_referral(options = {})
      referral = new_referral(options)
      referral.save!
      referral
    end

    def new_referral(options = {})
      defaults = {
        referred_by: 1,
        created_user_id: 10
      }

      ReferralConversionRecord.new(defaults.merge(options))
    end

    def new_tango_tracking(options = {})
      defaults = {
        user_id: 1,
        loot_id: 1,
        card_sku: 'sharknado',
        card_value: 15.00,
        recipient_name: 'Banana Hamrick',
        recipient_email: 'just-hamrick-it@example.com',
        sent_to_tango_on: 1.hour.ago,
        response_from_tango_on: 10.minutes.ago,
        response_type: 'SUCCESS',
        reference_order_id: '113-083696056-28',
        card_token: '521e2ff4e536f9.10739555',
        card_number: 'V732-AM9ABN-WYZR',
        card_pin: nil
      }

      TangoTrackingRecord.new(defaults.merge(options))
    end

    def create_tango_tracking(options = {})
      tango_tracking = new_tango_tracking(options)
      tango_tracking.save!
      tango_tracking
    end

    def new_tango_redemption_limit(options = {})
      defaults= {
        hold_redemptions: nil,
        user_id: 1,
        redemption_count: 0,
        redeemed_in_past_24_hours: nil
      }

      OpenStruct.new(defaults.merge(options))
    end

    def create_contest(options = {})
      contest = new_contest(options)
      contest.save!
      contest
    end

    def new_contest(options = {})
      defaults = {
        description: 'This is a contest\'s description',
        image: '/assets/profile.jpg',
        prize: 'This is the prize - a car!',
        start_time: 10.days.ago.to_date,
        end_time: 10.days.from_now.to_date,
        terms_and_conditions: 'This is a set of terms and conditions'
      }

      ContestRecord.new(defaults.merge(options))
    end

    def create_entry(options = {})
      new_entry(options).tap(&:save!)
    end

    def new_entry(options = {})
      defaults = {
        user_id: 1,
        contest_id: 1,
        provider: 'twitter',
        multiplier: 1,
        computed_entries: 1,
        referral_entries: 0
      }

      Plink::EntryRecord.new { |entry| apply(entry, defaults, options) }
    end


    def apply(object, defaults, overrides)
      options = defaults.merge(overrides)
      options.each do |method, value_or_proc|
        object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
      end
    end
  end
end
