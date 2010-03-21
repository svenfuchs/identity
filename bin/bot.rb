$: << File.expand_path('../../lib', __FILE__)
require 'identity'
require 'twibot'

CouchPotato::Config.database_name = "http://localhost:5984/rugb"

bot.add_handler(:reply, Identity::Listener::Twitter.new(/#update/, :update))