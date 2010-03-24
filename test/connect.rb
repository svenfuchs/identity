$: << File.expand_path('../lib', __FILE__)
require 'rubygems'
require 'identity'

module CouchPotato
  def self.database=(database)
    @@__database = database
  end
end

ENV['couchdb_url'] = ...
ENV['twitter_login'] = 'rugb_test'
ENV['twitter_password'] = 'clubmate'

# gotta do this to use http auth
ENV['couchdb_url'] =~ /(.*)\/([^\/]*)$/
couchdb_url, couchdb_name = $1, $2

couchrest_server = CouchRest::Server.new(couchdb_url)
couchrest_db = CouchRest::Database.new(couchrest_server, couchdb_name)
CouchPotato.database = CouchPotato::Database.new(couchrest_db)

p Identity.find_by_handle('fritzek')