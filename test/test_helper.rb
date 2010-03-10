$: << File.expand_path('../', __FILE__) 
$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'identity'
require 'test_declarative'
require 'mocha'
require 'twibot'

CouchPotato::Config.database_name = "http://localhost:5984/identity"

def fixture(filename)
  File.read(File.expand_path("../fixtures/#{filename}", __FILE__))
end
