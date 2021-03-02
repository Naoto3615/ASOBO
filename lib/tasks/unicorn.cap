namespace :unicorn do
  task :environment do
    set :unicorn_pid, "/var/www/deploy_app/shared/tmp/pids/unicorn.pid" # config/unicorn/production.rbないのpidと同じ
    set :unicorn_config, "#{current_path}/config/unicorn/production.rb"
  end

  def start_unicorn
    # フォルダが存在した場合のみ実行する
    within current_path do
    execute :bundle, :exec, :unicorn, "-c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
    end
  end

  def stop_unicorn
    execute :kill, "-s QUIT $(< #{fetch(:unicorn_pid)})"
  end

  def reload_unicorn
    execute :kill, "-s USR2 $(< #{fetch(:unicorn_pid)})" 
  end

  def force_stop_unicorn
    execute :kill, "$(< #{fetch(:unicorn_pid)})"
  end

  desc "Start unicorn server"
  task :start => :environment do
    on roles(:app) do
      start_unicorn
    end
  end

  desc "Stop unicorn server gracefully"
  task :stop => :environment do
    on roles(:app) do
      stop_unicorn
    end
  end

  desc "Restart unicorn server gracefully"
  task :restart => :environment do # TODO
    on roles(:app) do
      if test("[ -f #{fetch(:unicorn_pid)} ]")
        reload_unicorn
      else
        start_unicorn
      end
    end
  end

  desc "Stop unicorn server immediately"
  task :force_stop => :environment do # TODO
    on roles(:app) do
      force_stop_unicorn
    end
  end
end
