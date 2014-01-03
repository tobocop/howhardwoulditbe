require 'spec_helper'

describe 'free_awards:award_offer_add_bonuses' do
  include_context 'rake'

  let!(:virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:user) { create_user(first_name: 'Bilbo', email: 'rings@theshire.com') }
  let!(:users_virtual_currency) { create_users_virtual_currency(user_id: user.id, virtual_currency_id: virtual_currency.id) }
  let!(:wallet) { create_wallet(user_id: user.id) }
  let!(:user_eligible_for_offer_add_bonus) { create_user_eligible_for_offer_add_bonus(user_id: user.id, offers_virtual_currency_id: 6, is_awarded: false) }
  let!(:populated_wallet_item) { create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 6) }

  let!(:user_not_eligible) { create_user(first_name: 'Frodo', email: 'scared_look@themovies.com') }
  let!(:user_not_eligible_wallet) { create_wallet(user_id: user_not_eligible.id) }

  let!(:offer_add_bonus_award_type) { create_award_type(award_code: 'offer_add_bonus') }

  it 'awards users that have received a bonus notification and have added the offer within 72 hours' do
    Plink::FreeAwardRecord.should_receive(:new).with(
      {
        award_type_id: offer_add_bonus_award_type.id,
        currency_award_amount: 25,
        dollar_award_amount: 0.25,
        is_active: true,
        is_notification_successful: false,
        is_successful: true,
        user_id: user.id,
        users_virtual_currency_id: users_virtual_currency.id,
        virtual_currency_id: virtual_currency.id
      }
    ).and_call_original

    capture_stdout { subject.invoke }

    user.reload.currency_balance.should == 25
  end

  it 'does not award users that have received a bonus notification and have not added the offer' do
    populated_wallet_item.unassign_offer
    Plink::FreeAwardRecord.should_not_receive(:new)

    capture_stdout { subject.invoke }
  end

  it 'does not award users that have received a bonus notification and have added the offer after 72 hours' do
    user_eligible_for_offer_add_bonus.update_attribute('created_at', 3.days.ago - 1.second)
    Plink::FreeAwardRecord.should_not_receive(:new)

    capture_stdout { subject.invoke }
  end

  it 'does not award users that did not receive a bonus notification' do
    user_eligible_for_offer_add_bonus.update_attribute('user_id', user_not_eligible.id)
    Plink::FreeAwardRecord.should_not_receive(:new)

    capture_stdout { subject.invoke }
  end

  it 'does not award users that have already been awarded' do
    user_eligible_for_offer_add_bonus.update_attribute('is_awarded', true)
    Plink::FreeAwardRecord.should_not_receive(:new)

    capture_stdout { subject.invoke }
  end

  it 'does not award users twice that received the bonus notification and added the offer twice' do
    populated_wallet_item.unassign_offer
    open_wallet_item = Plink::WalletItemRecord.find(populated_wallet_item.id)
    open_wallet_item.assign_offer(double(id: 6), double(id: 1))
    Plink::FreeAwardRecord.should_receive(:new)
      .exactly(1).times
      .and_return(double(save: true))

    capture_stdout { subject.invoke }
  end

  it 'indicates that the user has been awarded for the bonus opportunity' do
    capture_stdout { subject.invoke }

    user_eligible_for_offer_add_bonus.reload.is_awarded.should be_true
  end

  it 'does not indicate that the user has been awarded for the bonus opportunity if the free award save fails' do
    Plink::FreeAwardRecord.any_instance.should_receive(:save).and_return(false)

    capture_stdout { subject.invoke }

    user_eligible_for_offer_add_bonus.reload.is_awarded.should be_false
  end
end

describe 'free_awards:populate_award_types' do
  include_context 'rake'

  it 'creates an award type for the 25 point bonus on an offer add bonus' do
    capture_stdout { subject.invoke }
    award_type = Plink::AwardTypeRecord.where(awardCode: 'offer_add_bonus').first
    award_type.email_message.should == 'for adding an offer to your Wallet'
  end
end
