require 'spec_helper'

describe 'white_label:convert_partner', skip_in_build: true do
  include_context 'rake'

  let!(:plink_points) { create_virtual_currency(subdomain: 'www', name: 'plink points') }
  let!(:reward_zone_points) { create_virtual_currency(subdomain: 'bestbuy', name: 'reward zone points') }
  let!(:user) { create_user }
  let!(:users_virtual_currency) {
    create_users_virtual_currency(
      user_id: user.id,
      virtual_currency_id: reward_zone_points.id,
      end_date: 100.years.from_now
    )
  }

  before do
    user.primary_virtual_currency = reward_zone_points
    user.save
  end

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'sets the users primary virtual currency to plink points' do
      subject.invoke('bestbuy')

      user.reload.primary_virtual_currency.should == plink_points
    end

    it 'end dates the old users virtual currency' do
      subject.invoke('bestbuy')

      users_virtual_currency.reload.end_date.to_date.should == Date.current
    end

    it 'creates a new users virtual currency record for the user with plink points' do
      subject.invoke('bestbuy')

      new_users_virtual_currency = Plink::UsersVirtualCurrencyRecord.last
      new_users_virtual_currency.user_id.should == user.id
      new_users_virtual_currency.virtual_currency_id.should == plink_points.id
      new_users_virtual_currency.start_date.to_date.should == Date.current
      new_users_virtual_currency.end_date.to_date.should > 100.years.from_now.to_date
    end
  end

  context 'when there are exceptions' do
    it 'requires a subdomain to be passed in' do
      expect {
        subject.invoke
      }.to raise_error ArgumentError
    end

    it 'logs record level exceptions' do
      Plink::UsersVirtualCurrencyRecord.stub(:create!).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /convert_whitelabel/
      end

      subject.invoke('bestbuy')
    end
  end
end
