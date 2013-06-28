require 'spec_helper'

describe Plink::WalletRecord do

  let(:valid_params) {
    {
        user_id: 143
    }
  }

  subject { Plink::WalletRecord.new(valid_params) }
  it_should_behave_like(:legacy_timestamps)

  describe 'create' do

    it 'can be created' do
      Plink::WalletRecord.create(valid_params).should be_persisted
    end

    it 'requires a user_id' do
      Plink::WalletRecord.new(valid_params.except(:user_id)).should_not be_valid
    end

  end

end