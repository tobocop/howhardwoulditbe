module FeatureSpecHelper

  def sign_in(email, password)
    visit '/'

    click_on 'Sign In'

    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Log in'
  end

  def award_points_to_user(args)
    award_type = create_award_type
    create_free_award(user_id: args[:user_id], dollar_award_amount: args[:dollar_award_amount], currency_award_amount: args[:currency_award_amount], award_type_id: award_type.id, virtual_currency_id: args[:virtual_currency_id])
  end

  def delete_users_from_gigya
    auth_params = URI.encode_www_form(
        apiKey: Gigya::Config.instance.api_key,
        secret: Gigya::Config.instance.secret
    )

    Plink::User.all.each do |user|
      `/usr/bin/curl -s "https://socialize-api.gigya.com/socialize.deleteAccount?uid=#{user.id}&#{auth_params}"`
    end
  end

end
