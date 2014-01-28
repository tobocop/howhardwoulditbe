namespace :user do
  desc 'Task to reset all tokens in the database'
  task reset_login_tokens: :environment do
    Plink::UserRecord.update_all("login_token =  REPLACE(CONVERT(varchar(255),newid()) + CONVERT(varchar(255),newid()), '-', '')")
  end
end
