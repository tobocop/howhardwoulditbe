module FeatureSpecHelper
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
        award_type = create_award_type(email_message: args[:award_message])

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

  def delete_users_from_gigya
    gigya = Gigya.new(Gigya::Config.instance)
    
    Plink::UserRecord.all.each do |user|
      gigya.delete_user(user.id)
    end
  end
end
