namespace :free_awards do
  desc 'Adds points to users accounts who have added the correct offer within 72 hours of receiving a bonus notification'
  task award_offer_add_bonuses: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning award_offer_add_bonuses";
      users_eligible_for_offer_add_bonuses.each do |user_eligible_for_offer_add_bonus|
        award_offer_add_bonus(user_eligible_for_offer_add_bonus)
      end
      puts "[#{Time.zone.now}] End of award_offer_add_bonuses"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle("award_offer_add_bonuses Rake task failed #{$!}")
    end
  end

  desc 'inserts the necessary free award types into the database'
  task populate_award_types: :environment do
    Plink::AwardTypeRecord.create(
      award_code: 'offer_add_bonus',
      award_display_name: 'Adding an offer',
      award_type: 'offer_add_bonus',
      email_message: 'for adding an offer to your Wallet',
      is_active: true
    )
  end

private

  def users_eligible_for_offer_add_bonuses
    Plink::UserEligibleForOfferAddBonusRecord
      .where('created_at >= ?', 3.days.ago)
      .where(is_awarded: false)
      .includes(:user_record)
  end

  def offer_add_bonus_award_type
    Plink::AwardTypeRecord.where(awardCode: 'offer_add_bonus').first
  end

  def get_users_virtual_currency(user_id, virtual_currency_id)
    Plink::UsersVirtualCurrencyRecord.where(userID: user_id, virtualCurrencyID: virtual_currency_id).first
  end

  def award_offer_add_bonus(user_eligible_for_offer_add_bonus)
    begin
      user = user_eligible_for_offer_add_bonus.user_record
      return unless user.wallet.has_offers_virtual_currency(user_eligible_for_offer_add_bonus.offers_virtual_currency_id)

      user.wallet.has_offers_virtual_currency(user_eligible_for_offer_add_bonus.offers_virtual_currency_id)
      users_virtual_currency = get_users_virtual_currency(user.id, user.primary_virtual_currency_id)

      free_award = Plink::FreeAwardRecord.new(
        award_type_id: offer_add_bonus_award_type.id,
        currency_award_amount: 25,
        dollar_award_amount: 0.25,
        is_active: true,
        is_notification_successful: false,
        is_successful: true,
        user_id: user.id,
        users_virtual_currency_id: users_virtual_currency.id,
        virtual_currency_id: user.primary_virtual_currency_id
      )

      if free_award.save
        puts "[#{Time.zone.now}] Awarded user_id: #{user.id}";
        user_eligible_for_offer_add_bonus.update_attribute('is_awarded', true)
      end
    rescue Exception
      message = "award_offer_add_bonuses failure for user.id = #{user.id}, "
      message << "user_eligible_for_offer_add_bonus.id = #{user_eligible_for_offer_add_bonus.id}"
      ::Exceptional::Catcher.handle("#{message} #{$!}")
    end
  end

  def stars
    puts '*' * 150
  end
end
