require 'bundler/capistrano'
load 'deploy/assets'

set :application, 'ant1word'
set :applicationdir, '/home/rails/projects/ant1word'
set :repository, 'https://github.com/Ant1Freezer/ant1word'
set :domain, 'dev.hostingconsult.ru'
ENV['RUBYPATH'] = '/opt/ruby-2.0.0-p247/bin/'

set :default_environment, {
      'PATH' => '/opt/ruby-2.0.0-p247/bin/:$PATH'
}

####################### DON'T MODIFY BELOW ############################

set :user, 'rails'
set :port, 22
ssh_options[:port] = 22
set :scm, :git
set :branch, 'master'

server domain, :app, :web, :db, :primary => true

set :deploy_to, applicationdir
set :deploy_via, :export  # or try :remote_cache - for using local repository

set :use_sudo, false

set :rails_env, 'production'
set :unicorn_conf, "#{applicationdir}/current/config/unicorn.rb"
set :unicorn_pid, "#{applicationdir}/shared/pids/unicorn.pid"

ssh_options[:user] = 'rails'
ssh_options[:keys] = [File.join(ENV['HOME'], '.ssh', 'id_rsa')]
ssh_options[:forward_agent] = true
# set :ssh_options, { :forward_agent => true }

shared_configs = %w'database.yml'

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :deploy do

  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end

  task :symlink_shared do
    shared_configs.each do |config|
      run "ln -s #{shared_path}/config/#{config} #{latest_release}/config/"
    end
  end


end


after 'deploy:finalize_update', 'deploy:symlink_shared'

after 'deploy:update', 'deploy:cleanup'
        require './config/boot'
        #require 'airbrake/capistrano'



