require 'spec_helper'

describe Plink::FreeAwardService do
  subject(:free_award_service) { Plink::FreeAwardService.new(3.56) }

  let(:user) { double(id: 98, primary_virtual_currency_id: 4) }
  let(:users_virtual_currency) { double(id: 12) }

  before do
    Plink::UserService.stub_chain(:new, :find_by_id).and_return(user)
    Plink::UsersVirtualCurrencyRecord.stub_chain(:where, :first).and_return(users_virtual_currency)
  end

  describe '#award_user_incented_affiliate' do
    before do
      Plink::AwardTypeRecord.stub(:incented_affiliate_award_type_id).and_return(34)
      free_award_service.stub(:award)
    end

    it 'looks up the appropriate award id' do
      Plink::AwardTypeRecord.should_receive(:incented_affiliate_award_type_id).and_return(34)

      free_award_service.award_user_incented_affiliate(98)
    end

    it 'calls award' do
      free_award_service.should_receive(:award).with(98, 34)

      free_award_service.award_user_incented_affiliate(98)
    end
  end

  describe '#award_referral_bonus' do
    before do
      Plink::AwardTypeRecord.stub(:referral_bonus_award_type_id).and_return(19)
      free_award_service.stub(:award)
    end

    it 'looks up the appropriate award id' do
      Plink::AwardTypeRecord.should_receive(:referral_bonus_award_type_id).and_return(19)

      free_award_service.award_referral_bonus(98)
    end

    it 'calls award' do
      free_award_service.should_receive(:award).with(98, 19)

      free_award_service.award_referral_bonus(98)
    end
  end

  describe '#award' do
    before do
      Plink::AwardTypeRecord.stub(:referral_bonus_award_type_id).and_return(19)
    end

    it 'looks up the user by id' do
      user_service = double
      Plink::UserService.should_receive(:new).and_return(user_service)
      user_service.should_receive(:find_by_id).with(98).and_return(user)

      free_award_service.award(98, 3)
    end

    it 'looks up the users virtual currency' do
      users_virtual_currencies = [users_virtual_currency]
      Plink::UsersVirtualCurrencyRecord.should_receive(:where).
        with(userID: 98, virtualCurrencyID: 4).
        and_return(users_virtual_currencies)

      free_award_service.award(98, 3)
    end

    it 'creates a free award by user id' do
     Plink::FreeAwardRecord.should_receive(:create).with({
        award_type_id: 3,
        currency_award_amount: 356,
        dollar_award_amount: 3.56,
        is_active: true,
        is_notification_successful: false,
        is_successful: true,
        user_id: 98,
        users_virtual_currency_id: 12,
        virtual_currency_id: 4
      })

      free_award_service.award(98, 3)
    end
  end
end
