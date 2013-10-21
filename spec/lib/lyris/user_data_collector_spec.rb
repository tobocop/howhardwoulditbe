require 'spec_helper'

describe Lyris::UserDataCollector do

  let!(:virtual_currency) { create_virtual_currency(name: 'plop points') }
  let(:birthday) { 10.years.ago.to_date }
  let(:user) {
    create_user(
      birthday: birthday,
      first_name: 'Melvin',
      is_male: 1,
      last_name: 'Hammrick',
      state: 'CO',
      zip: 80204
    )
  }
  let(:affiliate) { create_affiliate(has_incented_card_registration: true, has_incented_join: true) }

  let(:account_event_type) { create_event_type(name: Plink::EventTypeRecord.card_add_type) }
  let!(:account_event) {
    create_event(
      user_id: user.id,
      event_type_id: account_event_type.id,
      affiliate_id: affiliate.id
    )
  }

  let(:email_capture_event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }
  let!(:email_event) {
    create_event(
      user_id: user.id,
      event_type_id: email_capture_event_type.id,
      affiliate_id: affiliate.id
    )
  }

  describe 'initialize' do
    let(:lyris_user_data_collector) {Lyris::UserDataCollector.new(user.id, virtual_currency.name)}

    it 'initializes with a user_id' do
      lyris_user_data_collector.user_id.should === user.id
    end

    it 'initializes with a currency name' do
      lyris_user_data_collector.currency_name.should === 'plop points'
    end

    it 'sets the user' do
      lyris_user_data_collector.user.should_not be_nil
      lyris_user_data_collector.user.id.should == user.id
    end

    it 'sets the account_add_event' do
      lyris_user_data_collector.account_add_event.should_not be_nil
      lyris_user_data_collector.account_add_event.id.should == account_event.id
    end

    it 'sets the email_capture_event' do
      lyris_user_data_collector.email_capture_event.should_not be_nil
      lyris_user_data_collector.email_capture_event.id.should == email_event.id
    end
  end

  describe '#to_hash' do
    context 'with data' do
      let(:lyris_user_data_collector) {Lyris::UserDataCollector.new(user.id, virtual_currency.name)}

      it 'converts the data to a hash' do
        data_hash = lyris_user_data_collector.to_hash
        data_hash[:bank_registered].should be_true
        data_hash[:birthday].should == birthday.to_time
        data_hash[:first_name].should == 'Melvin'
        data_hash[:gender].should == 'Male'
        data_hash[:incentivized_on_card_reg].should be_true
        data_hash[:incentivized_on_join].should be_true
        data_hash[:is_subscribed].should be_true
        data_hash[:last_name].should == 'Hammrick'
        data_hash[:registration_affiliate_id].should == affiliate.id
        data_hash[:registration_date].to_date.should == email_event.created_at.to_date
        data_hash[:state].should == 'CO'
        data_hash[:user_id].should == user.id
        data_hash[:virtual_currency].should == 'plop points'
        data_hash[:zip].should == '80204'
      end
    end

    context 'without data' do
      let(:user_without_data) {
        create_user(
          email: 'bananas@plink.com',
          birthday: birthday,
          first_name: 'Melvin',
          is_male: 1,
          last_name: 'Hammrick',
          state: 'CO',
          zip: 80204
        )
      }

      let(:lyris_user_data_collector) {Lyris::UserDataCollector.new(user_without_data.id, virtual_currency.name)}

      it 'converts the data to a hash' do
        data_hash = lyris_user_data_collector.to_hash
        data_hash[:bank_registered].should be_false
        data_hash[:incentivized_on_card_reg].should be_false
        data_hash[:incentivized_on_join].should be_false
        data_hash[:is_subscribed].should be_true
        data_hash[:last_name].should == 'Hammrick'
        data_hash[:registration_affiliate_id].should == 0
        data_hash[:registration_date].should == nil
        data_hash[:state].should == 'CO'
        data_hash[:user_id].should == user_without_data.id
        data_hash[:virtual_currency].should == 'plop points'
        data_hash[:zip].should == '80204'
      end
    end
  end
end
