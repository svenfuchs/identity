$: << File.expand_path('../../lib', __FILE__)
require 'identity'

CouchPotato::Config.database_name = "http://localhost:5984/rugb"

Identity::Listener::Twitter.new(bot)
