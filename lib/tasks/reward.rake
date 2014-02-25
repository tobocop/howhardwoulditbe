namespace :reward do
  desc 'Sends out reward notifications to users who have earned Plink Points'
  task send_reward_notifications: :environment do
    begin
      award_records = Plink::AwardRecord.select('distinct userID').
        plink_point_awards_pending_notification

      award_records.each do |award_record|
        send_reward_notification(award_record)
      end
    rescue Exception
      ::Exceptional::Catcher.handle($!, "send_reward_notifications Rake task failed")
    end
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
      ::Exceptional::Catcher.handle($!, "#{message}")
    end
  end
end
