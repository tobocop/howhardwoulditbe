namespace :bestbuy do
  desc 'Task to convert all current bestbuy users to plink point users'
  task convert_users_to_plink_points: :environment do
    stars; puts "[#{Time.zone.now}] Beginning bestbuy:convert_users_to_plink_points"

    reward_zone_points = Plink::VirtualCurrency.find_by_sudomain('bestbuy').first
    plink_points = Plink::VirtualCurrency.default

    Plink::UserRecord.where(primaryVirtualCurrencyID: reward_zone_points.id).find_in_batches do |user_group|
      user_group.each do |user|
        begin
          Plink::UserRecord.transaction do
            bestbuy_users_virtual_currency = Plink::UsersVirtualCurrencyRecord.where(userID: user.id, virtualCurrencyID: reward_zone_points.id).first
            bestbuy_users_virtual_currency.update_attributes!(end_date: Date.current)

            Plink::UsersVirtualCurrencyRecord.create!(
              user_id: user.id,
              start_date: Date.current,
              virtual_currency_id: plink_points.id
            )

            user.primary_virtual_currency = plink_points
            user.save!
          end

          puts "[#{Time.zone.now}] Converted user #{user.id}"
        rescue Exception => e
          ::Exceptional::Catcher.handle($!, "bestbuy:convert_users_to_plink_points Rake task failed on user.id = #{user.id}")
        end
      end
    end

    puts "[#{Time.zone.now}] Ending bestbuy:convert_users_to_plink_points"; puts stars
  end

private

  def stars
    puts '*' * 150
  end
end

