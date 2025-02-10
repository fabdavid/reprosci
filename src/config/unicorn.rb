worker_processes 2 # Adjust this based on your server's CPU cores
timeout 30
preload_app true

# Path to the application
app_dir = File.expand_path("../..", __FILE__)
working_directory app_dir

# Set the environment to production
environment = ENV['RAILS_ENV'] || 'production'

# Log file paths
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

before_fork do |server, worker|
  # Signal the master process to quit after workers are done
  Signal.trap 'TERM' do
    puts 'Master stopping...'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |server, worker|
  # Any necessary setup after forking
end
