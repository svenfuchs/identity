$: << File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'sinatra'
require 'identity'

Dir[File.expand_path('../app/**/*', __FILE__)].each { |file| require file }

# should be set through heroku config:add
ENV['couchdb_url']      ||= 'http://localhost:5984'
ENV['twitter_login']    ||= 'rugb_test'
ENV['twitter_password'] ||= '...'

configure :production do
  # CouchPotato::Config.database_name = ENV['couchdb_url']
end

helpers do
  include Sinatra::Authorization
end

get '/ping' do
  protected!
  Identity::Poller::Twitter.new(:reply, /#update/, :update, {
    :login    => ENV['twitter_login'],
    :password => ENV['twitter_password'],
    :process  => 10420650959 # TODO replace with last processed tweet id
  }).run! && "ok"
end