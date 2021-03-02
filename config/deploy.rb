# config valid for current version and patch releases of Capistrano
lock "~> 3.15.0"

set :application, "ASOBO"
set :repo_url, "git@github.com:Naoto3615/ASOBO.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/ASOBO"
set :rbenv_type, :user
set :rbenv_ruby, '3.0.0'
set :rbenv_path, '/home/username/.rbenv'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
# リリースフォルダをいくつまで保持するか？
set :keep_releases, 5
set :deploy_via, :remote_cache

set :log_level, :debug # capistranoの出力ログの制御
set :pty, true # sudoを使用するのに必要
# Shared に入るものを指定
set :linked_files, %w{config/database.yml config/secrets.yml} # シンボリックリンクを貼るファイル
set :linked_dirs,  %w{bin log tmp/pids tmp/sockets tmp/cache vender/bundle } # sharedにシンボリックリンクを張るディレクトリ指定

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do


desc 'Restart application'
  # アプリ再起動を行うタスク
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, '-p', release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end
  # linked_files で使用するファイルをアップロードするタスク
  # deployが行われる前にコマンドにて実行する
  desc 'upload important files'
  task :upload do
    on roles(:app) do |host|
      execute :mkdir, '-p', "#{shared_path}/config"
      upload!('config/database.yml',"#{shared_path}/config/database.yml")
      upload!('config/secrets.yml',"#{shared_path}/config/secrets.yml")
    end
  end

  # webサーバー再起動時にキャッシュを削除する
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    #Here we can do anything such as:
    within release_path do
      execute :rm, '-rf', release_path.join('tmp/cache')
    end
  end
end
  # Flow の before, after のタイミングで上記タスクを実行
  before :started,   'deploy:upload'
  after  :finishing, 'deploy:cleanup'

  #unicorn 再起動タスク
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart' # lib/capustrano/tasks/unicorn.rake 内処理を呼び出す
  end
end



# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
