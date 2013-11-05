class InstitutionAccountPresenter
  attr_accessor :account_id, :active, :display_position, :name

  def initialize(intuit_account)
    @account_id = intuit_account[:account_id]
    @account_number = intuit_account[:account_number]
    @active = intuit_account[:status] == 'ACTIVE'
    @display_position = intuit_account[:display_position].to_i
    @name = intuit_account[:account_nickname]
  end

  def masked_account_number
    @account_number.sub(/^.*(.{4})/, '****-****-****-\1')
  end

  def to_hash
    {
      account_id: @account_id,
      account_number: masked_account_number,
      active: @active,
      display_position: @display_position,
      name: @name
    }
  end
end
