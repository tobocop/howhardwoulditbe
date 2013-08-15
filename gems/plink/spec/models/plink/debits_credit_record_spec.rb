require 'spec_helper'

describe Plink::DebitsCreditRecord do

  let(:virtual_currency) { create_virtual_currency(name: 'Ploink Points') }
  let(:user) { create_user(primary_virtual_currency: virtual_currency) }


  context 'readers' do

    before do
      award_type = create_award_type(email_message: 'my free award', award_type: 'my new one')
      create_free_award(user_id: user.id, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id, dollar_award_amount: 1.34, currency_award_amount: 134)
    end

    it 'can return a display_name' do
      record = Plink::DebitsCreditRecord.first
      record.award_display_name.should == 'my free award'
      record.dollar_award_amount.should == 1.34
      record.currency_award_amount.should == 134
      record.display_currency_name.should == 'Ploink Points'
      record.is_reward.should be_false
      record.award_type.should == 'my new one'
      Date.new(record.created.to_i) == Time.zone.today
    end
  end

  context 'types' do
    describe '.qualified_type' do
      it 'returns the string "qualified" for a qualified type' do
        Plink::DebitsCreditRecord.qualified_type.should == 'qualified'
      end

      it 'returns the string "Non-qualifying" for a non-qualified type' do
        Plink::DebitsCreditRecord.non_qualified_type.should == 'Non-qualifying'
      end

      it 'returns the string "Loot" for a redemption type' do
        Plink::DebitsCreditRecord.redemption_type.should == 'Loot'
      end
    end
  end

  describe 'is_reward' do
    before do
      reward = create_reward(name: 'Walmart Gift Card')
      create_redemption(reward_id: reward.id, user_id: user.id, dollar_award_amount: 3.00)
    end

    it 'returns true if the debit/credit is a reward' do
      Plink::DebitsCreditRecord.first.is_reward.should be_true
    end
  end

  describe 'award_type' do

    let(:users_virtual_currency) { create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id) }
    let(:advertiser) { create_advertiser }

    it 'returnes qualified for a qualified award' do
      create_qualifying_award(
        user_id: user.id,
        virtual_currency_id: virtual_currency.id,
        users_virtual_currency_id: users_virtual_currency.id,
        advertiser_id: advertiser.id
      )
      Plink::DebitsCreditRecord.first.award_type.should == 'qualified'
    end

    it 'returnes Non-qualifying for a qualified award' do
      create_non_qualifying_award(
        user_id: user.id,
        virtual_currency_id: virtual_currency.id,
        users_virtual_currency_id: users_virtual_currency.id,
        advertiser_id: advertiser.id
      )
      Plink::DebitsCreditRecord.first.award_type.should == 'Non-qualifying'
    end
  end
end
