module ControllerSpecHelper
  def set_current_user(overrides={})
    defaults = {
      id: 134,
      logged_in?: true,
      current_balance: 987,
      first_name: 'test_name',
      email: 'test@test.com',
      primary_virtual_currency_id: 1,
      valid?: true
    }
    user = double(:user, defaults.merge(overrides))
    controller.stub(current_user: user)
    user
  end

  def set_virtual_currency(overrides={})
    defaults = {
      subdomain: 'www',
      currency_name: 'Plink points',
      id: 100
    }

    virtual_currency = double(:virtual_currency, defaults.merge(overrides))
    controller.stub(current_virtual_currency: virtual_currency)
    virtual_currency
  end

  def set_auto_login_cookie(password_hash, cookie_name=:PLINKUID, options={})
    encoded_hash = Base64.encode64(password_hash)
    defaults = {
      value: encoded_hash,
      domain: :all,
      path: '/',
      expires: 1.hour.from_now
    }

    cookies[cookie_name] = defaults.merge(options)
  end
end
