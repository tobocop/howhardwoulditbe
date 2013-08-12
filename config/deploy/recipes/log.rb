namespace :log do

  desc 'tail Rails log'
  task :rails, roles: :app do
    trap("INT") { puts 'Interupted'; exit 0; }
    run "tail -f #{shared_path}/log/#{rails_env}.log" do |channel, stream, data|
      puts  # extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  desc 'tail unicorn log'
  task :unicorn, roles: :app do
    trap("INT") { puts 'Interupted'; exit 0; }
    run "tail -f #{shared_path}/log/unicorn_access.log" do |channel, stream, data|
      puts  # extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  desc 'tail unicorn error log'
  task :unicorn_error, roles: :app do
    trap("INT") { puts 'Interupted'; exit 0; }
    run "tail -f #{shared_path}/log/unicorn_error.log" do |channel, stream, data|
      puts  # extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

end
