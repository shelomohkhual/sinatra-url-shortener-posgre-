require 'bundler/setup'
Bundler.require

ENV['SINATRA_ENV'] ||= "development"

unless ENV['RACK_ENV'] == 'production'
    require 'dotenv'
    Dotenv.load
end


require_all 'app'
