$: << File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'sinatra'
require 'identity'

# should be set through heroku config:add
ENV['couchdb_url']      ||= 'http://localhost:5984/rugb'
ENV['twitter_login']    ||= 'rugb_test'
ENV['twitter_password'] ||= 'clubmate'

Dir[File.expand_path('../app/**/*', __FILE__)].each { |file| require file }

configure :production do
end

helpers do
  include Sinatra::Authorization
end

get '/ping' do
  protected!
  Identity::Poller::Twitter.new(:reply, /#update/, :update, {
    :login    => ENV['twitter_login'],
    :password => ENV['twitter_password'],
    :process  => Identity::Message.max_message_id || 10420650959
  }).run! && "ok"
end