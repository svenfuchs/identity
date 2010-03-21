require 'rubygems'
require 'sinatra'

configure :production do
  CouchPotato::Config.database_name = ENV['couchdb_url']
end

# TODO should be post, should require some secret
get '/ping' do
  Identity::Poller::Twitter.new(:reply, /#update/, :update, {
    :login    => ENV['admin_twitter_login'],
    :password => ENV['admin_twitter_password'],
    :process  => 10420650959 # TODO replace with last processed tweet id
  }).run! && "ok"
end