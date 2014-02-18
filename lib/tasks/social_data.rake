namespace :social_data do
  desc 'Generates a file of social profiles and uploads them to S3'
  task upload_to_s3: :environment do
    begin
      stars; puts "[#{Time.zone.now}] Beginning social_data:upload_to_s3"

      users_social_profiles = Plink::UsersSocialProfileRecord.all

      profiles_to_upload = Tempfile.open('profiles_to_upload')
      profiles_to_upload.puts 'user_id|gigya_profile'

      users_social_profiles.each do |users_social_profile|
        begin
          profiles_to_upload.puts "#{users_social_profile.user_id}|#{users_social_profile.profile.gsub(/\r\n/,'')}"
          puts "[#{Time.zone.now}] Uploading profile id: #{users_social_profile.id} with user_id = #{users_social_profile.user_id}"
        rescue Exception => e
          ::Exceptional::Catcher.handle("social_data:upload_to_s3 Rake task failed on users_social_profile.id = #{users_social_profile.id} with #{$!}")
        end
      end

      profiles_to_upload.close
      AWS::S3UploadService.new('plink-social-profiles', profiles_to_upload).upload_unique_csv
      users_social_profiles.map(&:destroy)

      puts "[#{Time.zone.now}] Ending social_data:upload_to_s3"; stars
    rescue Exception => e
      ::Exceptional::Catcher.handle("social_data:upload_to_s3 Rake task failed #{$!}")
    end
  end

private

  def stars
    puts '*' * 150
  end
end
