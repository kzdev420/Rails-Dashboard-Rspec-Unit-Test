deploy_to   = ENV['BACKEND_APP_PATH']
rails_root  = "#{deploy_to}"
pid_file    = "#{deploy_to}/tmp/pids/unicorn.pid"
socket_file = "#{deploy_to}/tmp/sockets/unicorn.sock"
log_file    = "#{rails_root}/log/unicorn.log"
err_log     = "#{rails_root}/log/unicorn_error.log"
old_pid     = pid_file + '.oldbin'

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 2)

# Load rails+github.git into the master before forking workers
# for super-fast worker spawn times
preload_app true

# Restart any workers that haven't responded in 30 seconds
timeout 30

# Listen on a Unix data socket
listen socket_file, backlog: 2048

# Pid file
pid pid_file

# Logs
stderr_path err_log
stdout_path log_file

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{rails_root}/Gemfile"
end

before_fork do |server, worker|
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
