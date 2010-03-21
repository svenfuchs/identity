$: << File.expand_path('../../lib', __FILE__)
require 'identity'

CouchPotato::Config.database_name = "..."

config = { 
  # credentials for rugb test account
  :login    => 'rugb_test', 
  :password => '...', 
  # last processed tweet id
  :process  => 10420650959
}
Identity::Poller::Twitter.new(:reply, /#update/, :update, config).run!