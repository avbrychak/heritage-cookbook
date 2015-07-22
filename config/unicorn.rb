# unicorn_rails --config-file config/unicorn.rb

rails_env = ENV['RAILS_ENV'] || 'development'
 
# 2 workers + 1 master
worker_processes 2
 
# Preload the app for instant fork
preload_app true
 
# Restart any workers that haven't responded in X seconds
# Some action can take time on big cookbooks
timeout 180
 
# Listen on a Unix data socket
if rails_env == 'production'
  listen "#{Dir.pwd}/tmp/sockets/unicorn.sock", backlog: 1024
else
  listen 3000
end
 
before_fork do |server, worker|

  # Disconnect from the database
  ActiveRecord::Base.connection.disconnect!
end
 
 
after_fork do |server, worker|

  # Connect to the database
  ActiveRecord::Base.establish_connection
end

# Nginx config:
# 
# upstream heritage {
#    server unix:/srv/app/heritage/current/tmp/sockets/unicorn.sock;
# }