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