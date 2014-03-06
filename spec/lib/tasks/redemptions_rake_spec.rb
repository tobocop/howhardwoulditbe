require 'spec_helper'

describe 'redemptions:check_daily_limit' do
  include_context 'rake'

  context 'when there are no exceptions' do
    before do
      Plink::TangoRedemptionShutoffService.stub(:halt_redemptions)
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'checks to see if we are at the daily limit' do
      Plink::TangoLimitService.should_receive(:past_daily_limit?).and_return(false)

      subject.invoke
    end

    context 'when daily limit has been reached' do
      before { Plink::TangoLimitService.stub(:past_daily_limit?).and_return(true) }

      it 'shuts off tango redemptions' do
        Plink::TangoRedemptionShutoffService.should_receive(:halt_redemptions)

        subject.invoke
      end

      it 'sends an email' do
        mail = double
        AllPlinkNotificationMailer.should_receive(:tango_over_daily_limit).and_return(mail)
        mail.should_receive(:deliver)

        subject.invoke
      end
    end

    context ' when daily limit has not been reached' do
      before { Plink::TangoLimitService.stub(:past_daily_limit?).and_return(false) }

      it 'does not shut off tango redemptions' do
        Plink::TangoRedemptionShutoffService.should_not_receive(:halt_redemptions)

        subject.invoke
      end

      it 'does not send an email' do
        AllPlinkNotificationMailer.should_not_receive(:tango_over_daily_limit)

        subject.invoke
      end
    end
  end

  context 'when there are exceptions' do
    it 'logs failures to Exceptional with the Rake task name' do
      Plink::TangoLimitService.stub(:past_daily_limit?).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /redemptions:check_daily_limit/
      end

      subject.invoke
    end
  end

  context 'integration' do
    before do
      create_tango_tracking(card_value: 2600.00)
      create_reward(is_redeemable: true, is_tango: true)
    end

    it 'makes sure everything is defined' do
      Plink::RewardRecord.where(is_redeemable: true).length.should == 1

      subject.invoke

      Plink::RewardRecord.where(is_redeemable: true).length.should == 0
    end
  end
end
