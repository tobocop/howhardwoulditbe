module FactoryTestHelpers
  def new_virtual_currency
    VirtualCurrency.new(name: "Plink Points", subdomain: "www", exchange_rate: 100, site_name: "Plink", singular_name: "Plink Point")
  end

  def create_virtual_currency
    virtual_currency = new_virtual_currency
    virtual_currency.save!
    virtual_currency
  end

  def new_user
    User.new(email: "test@example.com")
  end

  def create_user
    user = new_user
    user.save!
    user
  end
end
