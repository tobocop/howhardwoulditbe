namespace :reward do
  desc 'Sends out reward notifications to users who have earned Plink Points'
  task send_reward_notifications: :environment do
    begin
      award_records = Plink::AwardRecord.select('distinct userID').
        plink_point_awards_pending_notification

      award_records.each do |award_record|
        send_reward_notification(award_record)
      end
    rescue Exception => e
      ::Exceptional::Catcher.handle("send_reward_notifications Rake task failed #{$!}")
    end
  end

  desc 'One time task to insert khols as a tango card redemption with the correct amounts'
  task insert_khols: :environment do
    Plink::RewardRecord.create(
      award_code: 'kohls-gift-card',
      description: "Expect great things when you shop Kohl's for apparel, shoes, accessories, home products and more!",
      display_order: 2,
      name: "Kohl's Gift Card",
      is_active: true,
      is_redeemable: true,
      is_tango: true,
      logo_url: 'http://plink-images.s3.amazonaws.com/giftcards/logos/kohls.png',
      terms: "Kohl's e-Gift Cards are redeemable for merchandise in any Kohl's store or online at Kohls.com. Kohl's e-Gift Cards are issued by and represent an obligation of Kohl's Value Services, Inc. Except where required by law, Kohl's e-Gift Cards are non-refundable, may not be redeemed for cash or for the purchase of Gift Cards and cannot be applied to any Kohl's Charge account balance. Kohl's e-Gift Cards have no expiration date. Purchaser is responsible for providing a deliverable e-mail address. Delivery of all Kohl's e-Gift Cards will be electronic and is subject to payment authorization barring any technical difficulties. A plastic Gift Card will not be sent. The unused value of lost or stolen e-Gift Cards can be replaced with required proof of purchase. E-mail general.help@kohls.com or see store for details. Card balance may be obtained by calling 1-800-655 -0554 or online at Kohls.com. KOHL'S VALUE SERVICES, INC., NOR ANY OF ITS AFFILIATES, MAKES ANY WARRANTIES, EXPRESS OR IMPLIED, WITH RESPECT TO KOHL'S E-GIFT CARDS, INCLUDING, WITHOUT LIMITATION, ANY EXPRESS OR IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. IN THE EVENT OF ANY PROBLEMS WITH AN E-GIFT CARD, INCLUDING BUT NOT LIMITED TO A NONFUNCTIONAL E-GIFT CARD CODE, YOUR SOLE REMEDY, AND KOHL'S SOLE LIABILITY, SHALL BE THE REPLACEMENT OF SUCH E-GIFT CARD. IF ANY PART OF THIS LIMITATION OF LIABILITY IS DETERMINED TO BE UNENFORCEABLE OR INVALID FOR ANY REASON, THE AGGREGATE LIABILITY OF KOHL'S VALUE SERVICES, INC. UNDER SUCH CIRCUMSTANCES FOR LIABILITIES THAT OTHERWISE WOULD HAVE BEEN LIMITED SHALL NOT EXCEED ONE HUNDRED DOLLARS ($100).",
      amounts: [
        Plink::RewardAmountRecord.new(dollar_award_amount: 25, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 50, is_active: true),
        Plink::RewardAmountRecord.new(dollar_award_amount: 100, is_active: true)
      ]
    )
  end

private

  def get_reward(award_record)
    if award_record.free_award_id
      Plink::FreeAwardRecord.find(award_record.free_award_id)
    elsif award_record.qualifying_award_id
      Plink::QualifyingAwardRecord.find(award_record.qualifying_award_id)
    elsif award_record.non_qualifying_award_id
      Plink::NonQualifyingAwardRecord.find(award_record.non_qualifying_award_id)
    end
  end

  def default_virtual_currency_presenter
    @virtual_currency ||= VirtualCurrencyPresenter.new(virtual_currency: Plink::VirtualCurrency.default)
  end

  def create_reward_open_structs(award_records)
    award_records.map do |award_record|
      OpenStruct.new(
        award_display_name: award_record.award_display_name,
        currency_award_amount: default_virtual_currency_presenter.amount_in_currency(award_record.dollar_award_amount)
      )
    end
  end

  def send_reward_notification(award_record)
    begin
      user = Plink::UserService.new.find_by_id(award_record.user_id)
      user_rewards = Plink::AwardRecord.where('userID = ?', user.id).
        plink_point_awards_pending_notification.all

      rewards = create_reward_open_structs(user_rewards)
      user_token = AutoLoginService.generate_token(user.id)
      RewardMailer.delay.reward_notification_email(
        email: user.email,
        rewards: rewards,
        user_currency_balance: default_virtual_currency_presenter.amount_in_currency(user.current_balance),
        user_token: user_token
      )

      user_rewards.each do |users_reward|
        reward = get_reward(users_reward)
        reward.update_attributes(is_notification_successful: true)
      end
    rescue Exception
      message = "send_reward_notifications failure for user.id = #{award_record.user_id}"
      ::Exceptional::Catcher.handle("#{message} #{$!}")
    end
  end
end
