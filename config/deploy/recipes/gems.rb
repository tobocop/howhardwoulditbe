namespace :gems do

  desc 'Run bundle install command for gem dependencies'
  task :bundle_install do
    gems = ['plink', 'plink_admin', 'tango', 'gigya']
    gems.each do |gem_name|
      run `cd #{release_path}; cd gems/#{gem_name}; env ARCHFLAGS="-arch x86_64" RAILS_ENV=#{rails_env} bundle install --path #{shared_path}/bundle --deployment --quiet --without development test;`
    end
  end
  after 'deploy:update_code', 'gems:bundle_install'

end
