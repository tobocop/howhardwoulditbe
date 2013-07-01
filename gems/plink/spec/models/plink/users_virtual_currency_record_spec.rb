require 'spec_helper'

describe Plink::UsersVirtualCurrencyRecord do

  let (:valid_params) {
    {
      start_date: '1900-01-01',
      user_id: 1,
      virtual_currency_id: 2
    }
  }

  subject { Plink::UsersVirtualCurrencyRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be valid' do
    Plink::UsersVirtualCurrencyRecord.create(valid_params).should be_persisted
  end
end