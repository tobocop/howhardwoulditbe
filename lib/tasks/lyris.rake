namespace :lyris do
  desc "Updates plink point users in lyris who have a modified record of yesterday"
  task update_modified_users: :environment do
    plink_users_modified_yesterday.each do |user|
      StatsD.increment('rake.lyris.update_modified_users')
      lyris_data = Lyris::UserDataCollector.new(user.id, user.primary_virtual_currency.name)
      lyris_user = Lyris::User.new(Lyris::Config.instance, user.email, lyris_data.to_hash)

      lyris_response = lyris_user.update
      lyris_response = lyris_user.add_to_list if lyris_response.data == "Can't find email address"

      if !lyris_response.successful? && Rails.env.production?
        msg = "lyris_rake#update_modified_users failed for user_id: #{user.id}, email: #{user.email}, error #{lyris_response.data}"
        ::Exceptional::Catcher.handle(Exception.new(msg))
      end
    end
  end

private

  def plink_users_modified_yesterday
    Plink::UserRecord.where('modified > ?', 1.day.ago.to_date)
      .where('modified < ?',  Date.current)
      .where('primaryVirtualCurrencyID = ?', Plink::VirtualCurrency.default.id)
  end
end

