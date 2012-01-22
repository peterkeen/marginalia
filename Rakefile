#!/usr/bin/env rake
#-*-ruby-*-
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Ideas::Application.load_tasks

task :deploy do
  sh "git push heroku master"
  sh "heroku run bundle exec rake db:migrate"
  sh "heroku ps:restart web"
end
