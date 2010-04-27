default_run_options[:pty] = true

set :application, 'rifgraf'

set :scm,         :git
set :repository,  'git://github.com/theworkinggroup/rifgraf.git'
set :deploy_via,  :remote_cache

set :use_sudo,  false

set :keep_releases, 1

task :production do
  set :user,      'postage'
  set :domain,    'web1.blue.postageapp.com'
  set :deploy_to, "/web/#{application}"
  set :branch,    'master'
  
  role :web,  domain
  role :app,  domain
  role :db,   domain, :primary => true
end


namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  task :stop, :roles => :app do
    # no-op
  end
  
  task :restart, :roles => :app do
    deploy.stop
    deploy.start
  end
end