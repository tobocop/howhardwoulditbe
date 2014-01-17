require 'spec_helper'

describe 'reward:send_reward_notifications' do
  include_context 'rake'
  let!(:virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:user_with_no_awards) { create_user }
  let!(:user_with_three_awards) { create_user(email: 'spelling@joesspellingacademy.com') }
  let!(:award_type) { create_award_type(email_message: 'for Bananas are awesome') }
  let!(:advertiser) { create_advertiser(advertiser_name: 'angry birds') }
  let(:valid_award_params) {
    {
      user_id: user_with_three_awards.id,
      is_notification_successful: false,
      is_active: true,
      is_successful: true,
      virtual_currency_id: virtual_currency.id
    }
  }
  let!(:free_award) {
    create_free_award(
      valid_award_params.merge(
        award_type_id: award_type.id,
        dollar_award_amount: 1.0
      )
    )
  }
  let!(:qualifying_award) {
    create_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 2.0
      )
    )
  }
  let!(:non_qualifying_award) {
    create_non_qualifying_award(
      valid_award_params.merge(
        advertiser_id: advertiser.id,
        dollar_award_amount: 3.0
      )
    )
  }

  it 'send a delayed email to users with an auto login token who have pending rewards' do
    reward_mail = double(deliver: true)
    delay = double(reward_notification_email: reward_mail)

    AutoLoginService.should_receive(:generate_token)
      .with(user_with_three_awards.id)
      .and_return('my_token')

    RewardMailer.should_receive(:delay).and_return(delay)

    delay.should_receive(:reward_notification_email) do |args|
      args[:email].should == 'spelling@joesspellingacademy.com'
      args[:rewards].map(&:award_display_name).should =~ ['Bananas are awesome', 'visiting angry birds', 'visiting angry birds']
      args[:rewards].map(&:currency_award_amount).should =~ ['100', '200', '300']
      args[:user_currency_balance].should == '600'
      args[:user_token].should == 'my_token'
      reward_mail
    end

    subject.invoke
  end

  it 'updates rewards to set is_notification_successful to true that were processed' do
    Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 3

    Plink::FreeAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original
    Plink::QualifyingAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original
    Plink::NonQualifyingAwardRecord.any_instance.should_receive(:update_attributes)
      .with(is_notification_successful: true)
      .and_call_original

    subject.invoke

    Plink::AwardRecord.where('isNotificationSuccessful = ?', 0).length.should == 0
  end

  it "gets distinct user id's  with awards pending notification" do
    award_select = double(:plink_point_awards_pending_notification)
    Plink::AwardRecord.should_receive('select').with('distinct userID')
      .and_return(award_select)
    award_select.should_receive(:plink_point_awards_pending_notification)
      .and_return([])

    subject.invoke
  end

  it 'logs record-level exceptions to Exceptional with the Rake task name' do
    Plink::UserService.stub(:new).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/send_reward_notifications/)

    subject.invoke
  end

  it 'includes the user.id in the record-level exception text' do
    AutoLoginService.stub(:generate_token).and_raise(Exception)

    ::Exceptional::Catcher.should_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end

  it 'logs Rake task-level failures to Exceptional with the Rake task name' do
    Plink::AwardRecord.stub(:select).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_receive(:handle).with(/send_reward_notifications/)

    subject.invoke
  end

  it 'does not include user.id in the task-level exception text' do
    Plink::AwardRecord.stub(:select).and_raise(ActiveRecord::ConnectionNotEstablished)

    ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id = \d+/)

    subject.invoke
  end
end

describe 'reward:insert_khols' do
  include_context 'rake'

  it 'inserts khols with the correct amounts' do
    subject.invoke

    khols = Plink::RewardRecord.last
    khols.amounts.map(&:dollar_award_amount).map(&:to_i).should == [25, 50, 100]
    khols.award_code.should == 'kohls-gift-card'
    khols.description.should == "Expect great things when you shop Kohl's for apparel, shoes, accessories, home products and more!"
    khols.display_order.should == 2
    khols.is_active.should be_true
    khols.is_redeemable.should be_true
    khols.is_tango.should be_true
    khols.logo_url.should == 'http://plink-images.s3.amazonaws.com/giftcards/logos/kohls.png'
    khols.name.should == "Kohl's Gift Card"
    khols.terms.should == "Kohl's e-Gift Cards are redeemable for merchandise in any Kohl's store or online at Kohls.com. Kohl's e-Gift Cards are issued by and represent an obligation of Kohl's Value Services, Inc. Except where required by law, Kohl's e-Gift Cards are non-refundable, may not be redeemed for cash or for the purchase of Gift Cards and cannot be applied to any Kohl's Charge account balance. Kohl's e-Gift Cards have no expiration date. Purchaser is responsible for providing a deliverable e-mail address. Delivery of all Kohl's e-Gift Cards will be electronic and is subject to payment authorization barring any technical difficulties. A plastic Gift Card will not be sent. The unused value of lost or stolen e-Gift Cards can be replaced with required proof of purchase. E-mail general.help@kohls.com or see store for details. Card balance may be obtained by calling 1-800-655 -0554 or online at Kohls.com. KOHL'S VALUE SERVICES, INC., NOR ANY OF ITS AFFILIATES, MAKES ANY WARRANTIES, EXPRESS OR IMPLIED, WITH RESPECT TO KOHL'S E-GIFT CARDS, INCLUDING, WITHOUT LIMITATION, ANY EXPRESS OR IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN THE EVENT OF ANY PROBLEMS WITH AN E-GIFT CARD, INCLUDING BUT NOT LIMITED TO A NONFUNCTIONAL E-GIFT CARD CODE, YOUR SOLE REMEDY, AND KOHL'S SOLE LIABILITY, SHALL BE THE REPLACEMENT OF SUCH E-GIFT CARD. IF ANY PART OF THIS LIMITATION OF LIABILITY IS DETERMINED TO BE UNENFORCEABLE OR INVALID FOR ANY REASON, THE AGGREGATE LIABILITY OF KOHL'S VALUE SERVICES, INC. UNDER SUCH CIRCUMSTANCES FOR LIABILITIES THAT OTHERWISE WOULD HAVE BEEN LIMITED SHALL NOT EXCEED ONE HUNDRED DOLLARS ($100)."
  end
end
