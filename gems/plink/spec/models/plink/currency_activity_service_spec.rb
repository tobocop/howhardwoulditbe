require 'spec_helper'

describe Plink::CurrencyActivityService do
  let(:user) {create_user}

  before do
    virtual_currency = create_virtual_currency
    award_type = create_award_type(email_message: 'my free award')
    advertiser = create_advertiser
    @free_award = create_free_award(user_id: user.id, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id, dollar_award_amount: 4324)
    @qualifying_award = create_qualifying_award(user_id: user.id, virtual_currency_id: virtual_currency.id, advertiser_id: advertiser.id, dollar_award_amount: 23498)

    award_for_other_user = create_free_award(user_id: user.id + 1, award_type_id: award_type.id, virtual_currency_id: virtual_currency.id)
  end

  describe 'get_for_user_id' do
    it 'returns all activity for free awards [and...]' do
      activity = subject.get_for_user_id(user.id)

      activity.map(&:dollar_award_amount).should == [@qualifying_award.dollar_award_amount, @free_award.dollar_award_amount]

      activity.each.map(&:class).should == [Plink::DebitsCredit, Plink::DebitsCredit]
    end

    it 'only returns the amount of records specified by NUMBER_OF_ITEMS' do
      subject.stub(number_of_records_to_return: 1)

      subject.get_for_user_id(user.id).length.should == 1
    end
  end
end
