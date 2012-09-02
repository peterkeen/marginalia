#-*-ruby-*-

worker_processes 3
timeout 30
preload_app true

before_fork do |server, number|
  @dj_pid ||= spawn('bundle exec rake jobs:work')
end

after_fork do |server, worker|
  ::ActiveRecord::Base.establish_connection
  ::Vanity.playground.establish_connection
end
