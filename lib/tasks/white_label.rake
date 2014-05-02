namespace :white_label do
  desc 'Task to convert all current bestbuy users to plink point users'
  task :convert_partner, [:subdomain] => :environment do |t, args|
    stars; puts "[#{Time.zone.now}] Beginning white_label:convert_whitelabel"

    subdomain = args[:subdomain]
    raise ArgumentError.new('subdomain is required') unless subdomain.present?


    white_label_currency = Plink::VirtualCurrency.find_by_sudomain(subdomain).first
    plink_points = Plink::VirtualCurrency.default

    Plink::UserRecord.where(primaryVirtualCurrencyID: white_label_currency.id).find_in_batches do |user_group|
      user_group.each do |user|
        begin
          Plink::UserRecord.transaction do
            old_users_virtual_currency = Plink::UsersVirtualCurrencyRecord.where(userID: user.id, virtualCurrencyID: white_label_currency.id).first
            old_users_virtual_currency.update_attributes!(end_date: Date.current)

            Plink::UsersVirtualCurrencyRecord.create!(
              user_id: user.id,
              start_date: Date.current,
              virtual_currency_id: plink_points.id
            )

            user.primary_virtual_currency = plink_points
            unless user.save
              puts "[#{Time.zone.now}] Did not convert user #{user.id}, errors: #{user.errors.full_messages.join('|')}"
              raise ActiveRecord::Rollback, "Call tech support!"
            else
              puts "[#{Time.zone.now}] Converted user #{user.id}"
            end
          end

        rescue Exception => e
          ::Exceptional::Catcher.handle($!, "white_label:convert_whitelabel Rake task failed on user.id = #{user.id}")
        end
      end
    end

    puts "[#{Time.zone.now}] Ending white_label:convert_whitelabel"; puts stars
  end

private

  def stars
    puts '*' * 150
  end
end

