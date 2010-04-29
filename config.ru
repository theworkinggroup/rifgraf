require 'rubygems'
require 'sinatra'
require 'sequel'
require 'json'
require 'yaml'
require 'main'

HOME_URL = {
  'development' => 'http://rifgraf.local',
  'production'  => 'http://rif.graf.postageapp.local'
}

root_dir = File.dirname(__FILE__)

set :environment, ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    File.join(root_dir, 'main.rb')
disable :run

run Sinatra::Application 
