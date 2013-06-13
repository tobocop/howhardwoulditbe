module FactoryTestHelpers
  def new_virtual_currency
    VirtualCurrency.new(name: "Plink Points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")
  end

  def create_virtual_currency
    virtual_currency = new_virtual_currency
    virtual_currency.save!
    virtual_currency
  end

  def new_user(options = {})
    defaults = {email: "test@example.com", first_name: "Joe", password_hash: "1234567890sdfghjkl", salt: "my-uuid"}
    User.new(defaults)
  end

  def create_user(options = {})
    user = new_user(options)
    user.save!
    user
  end
end
