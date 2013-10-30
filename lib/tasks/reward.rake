namespace :reward do
  desc 'Sends out reward notifications to users who have earned Plink Points'
  task send_reward_notifications: :environment do
    award_records = Plink::AwardRecord.select('distinct userID')
      .plink_point_awards_pending_notification

    award_records.each do |award_record|
      user = Plink::UserService.new.find_by_id(award_record.user_id)
      user_rewards = Plink::AwardRecord.where('userID = ?', user.id)
        .plink_point_awards_pending_notification.all

      rewards = create_reward_open_structs(user_rewards)
      user_token = AutoLoginService.generate_token(user.id)
      RewardMailer.delay.reward_notification_email(
        email: user.email,
        rewards: rewards,
        user_currency_balance: user.currency_balance,
        user_token: user_token
      )

      user_rewards.each do |users_reward|
        reward = get_reward(users_reward)
        reward.update_attributes(is_notification_successful: true)
      end
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

  def create_reward_open_structs(award_records)
    award_records.map do |award_record|
      OpenStruct.new(
        award_display_name: award_record.award_display_name,
        currency_award_amount: award_record.currency_award_amount
      )
    end
  end
end
