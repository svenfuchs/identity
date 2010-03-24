$: << File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'sinatra'
require 'identity'

# gotta hack a bit for http auth
ENV['couchdb_url'] =~ /(.*)\/([^\/]*)$/
couchdb_url, couchdb_name = $1, $2

module CouchPotato
  def self.database=(database)
    @@__database = database
  end
end

couchrest_server = CouchRest::Server.new(couchdb_url)
couchrest_db = CouchRest::Database.new(couchrest_server, couchdb_name)
CouchPotato.database = CouchPotato::Database.new(couchrest_db)

configure :production do
  # CouchPotato::Config.database_name = ENV['couchdb_url']
end

# TODO should be post, should require some secret
get '/ping' do
  Identity::Poller::Twitter.new(:reply, /#update/, :update, {
    :login    => ENV['twitter_login'],
    :password => ENV['twitter_password'],
    :process  => 10420650959 # TODO replace with last processed tweet id
  }).run! && "ok"
end