class NullUserPresenter

  def primary_virtual_currency_id
    Plink::VirtualCurrency.default.id
  end

  def logged_in?
    false
  end
end