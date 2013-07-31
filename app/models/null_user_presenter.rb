class NullUserPresenter

  def id
    nil
  end

  def primary_virtual_currency_id
    Plink::VirtualCurrency.default.id
  end

  def logged_in?
    false
  end

  def can_redeem?
    false
  end
end