namespace :export_users do
  desc 'Exports a CSV of users who were removed from Intuit due to having 103 errors'
  task users_removed_for_103_errors: :environment do
    exported_users = PlinkAdmin::UserQueryService.users_removed_for_103_errors

    CSV.open('users_removed_for_103_errors.csv','w',{ force_quotes:true }) do |csv|
      header_row = exported_users[0].keys << 'token'
      csv << header_row

      exported_users.each do |user|
        user_row = user.values << login_token(user)
        csv << user_row
      end
    end
  end

  private

  def login_token(user_record)
    AutoLoginService.generate_token(user_record['user_id'].to_i)
  end
end
