#-*-ruby-*-

worker_processes 3
timeout 30

before_fork do |server, number|
  @dj_pid ||= spawn('bundle exec rake jobs:work')
end
