module FeatureSpecHelper

  def create_app_user(args)
    virtual_currency = create_virtual_currency(subdomain: Plink::VirtualCurrency::DEFAULT_SUBDOMAIN)
    user = create_user(email: args[:email], primary_virtual_currency: virtual_currency)
    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id)
    create_locked_wallet_item(wallet_id: wallet.id)
  end

  def award_points_to_user(args)

    case args[:type]
      when 'qualifying'
        create_qualifying_award(
          currency_award_amount: args[:currency_award_amount],
          dollar_award_amount: args[:dollar_award_amount],
          user_id: args[:user_id],
          virtual_currency_id: args[:virtual_currency_id],
          users_virtual_currency_id: args[:users_virtual_currency_id],
          advertiser_id: args[:advertiser_id]
        )
      when 'nonqualifying'
        create_non_qualifying_award(
          currency_award_amount: args[:currency_award_amount],
          dollar_award_amount: args[:dollar_award_amount],
          user_id: args[:user_id],
          virtual_currency_id: args[:virtual_currency_id],
          users_virtual_currency_id: args[:users_virtual_currency_id],
          advertiser_id: args[:advertiser_id]
        )
      else
        award_type = create_award_type(
          email_message: args[:award_message], 
          award_display_name: args.fetch(:award_message, 'Message')
        )

        create_free_award(
          user_id: args[:user_id],
          dollar_award_amount: args[:dollar_award_amount],
          currency_award_amount: args[:currency_award_amount],
          virtual_currency_id: args[:virtual_currency_id],
          award_type_id: award_type.id
        )
    end
  end

  def link_card_for_user(user_id)
    create_oauth_token(user_id: user_id)
    create_users_institution_account(user_id: user_id)
  end

  def sign_in_admin(email='my_admin@example.com', password='password')
    create_admin unless email.present?
    visit '/plink_admin'
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
  end

  def delete_users_from_gigya
    gigya = Gigya.new(Gigya::Config.instance)
    
    Plink::UserRecord.all.each do |user|
      gigya.delete_user(user.id)
    end
  end
end
