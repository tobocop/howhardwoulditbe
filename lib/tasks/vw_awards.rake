namespace :vw_awards do
  desc 'One-time task to add email_message to vw_awards'
  task add_email_message_to_vw_awards: :environment do
    ActiveRecord::Base.connection.execute(File.read(Rails.root.join('db', 'scripts', 'alter_vw_awards.sql')))
  end
end
