namespace :apache do
  %w[start stop restart].each do |command|
    desc "#{command} apache"
    task command, roles: :web do
      run "#{sudo} service apache2 #{command}"
    end
  end
end
