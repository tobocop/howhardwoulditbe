require 'spec_helper'

describe Plink::DebitsCredit do
  let(:user) { create_user }

  before do
    virtual_currency = create_virtual_currency
    award_type = create_award_type(email_message: 'my free award')
    create_free_award(user_id: user.id, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id, dollar_award_amount: 1.43, currency_award_amount: 143)
  end

  it 'should delegate attributes to the given debits credit record' do
    debits_credit = Plink::DebitsCredit.new(Plink::DebitsCreditRecord.where(userID: user.id).first)

    debits_credit.award_display_name.should == 'my free award'
    debits_credit.dollar_award_amount.should == 1.43
    debits_credit.awarded_on.should == Time.zone.today
    debits_credit.currency_award_amount.should == '143'
    debits_credit.display_currency_name.should == 'Plink points'
    debits_credit.is_reward?.should == false
    debits_credit.is_qualified?.should == false
    debits_credit.is_non_qualified?.should == false
    debits_credit.is_free?.should == true
  end
end
