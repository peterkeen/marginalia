# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == ENV['DJ_USER']
    password == ENV['DJ_PASS']
  end
end
use Rack::Deflater
run Ideas::Application
