shared_context 'legacy_wallet_items' do

  let(:legacy_open_wallet_item) { create_legacy_wallet_item('open') }
  let(:legacy_populated_wallet_item) { create_legacy_wallet_item('populated') }
  let(:wallet) { create_wallet }

end

def create_legacy_wallet_item(type)
  period_id = type == 'open' ? nil : 100

  wallet_attrs = {
    :wallet_id => wallet.id,
    :wallet_slot_id => 0,
    :wallet_slot_type_id => 0,
    :users_award_period_id => period_id,
    :offers_virtual_currency_id => nil,
    :type => nil
  }

  Plink::WalletItemRecord.new { |record| apply(record, wallet_attrs, {}) }.tap(&:save!)
end

def create_legacy_wallet_slot(type)
  period_id = type == 'open' ? nil : 100

  wallet_attrs = {
    :wallet_id => wallet.id,
    :wallet_slot_id => 0,
    :wallet_slot_type_id => 0,
    :users_award_period_id => period_id,
    :offers_virtual_currency_id => nil,
    :type => nil
  }

  Plink::WalletItemRecord.new { |record| apply(record, wallet_attrs, {}) }.tap(&:save!)
end


def apply(object, defaults, overrides)
  options = defaults.merge(overrides)
  options.each do |method, value_or_proc|
    object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
  end
end
