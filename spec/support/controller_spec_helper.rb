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
    user = mock(:user, defaults.merge(overrides))
    controller.stub(current_user: user)
    user
  end

  def set_virtual_currency(overrides={})
    defaults = {
      subdomain: 'www',
      currency_name: 'Plink points',
      id: 100
    }

    virtual_currency = mock(:virtual_currency, defaults.merge(overrides))
    controller.stub(current_virtual_currency: virtual_currency)
    virtual_currency
  end
end