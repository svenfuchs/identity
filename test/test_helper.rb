$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'identity'
require 'test_declarative'
require 'mocha'
require 'twibot'

CouchPotato::Config.database_name = "http://localhost:5984/identity"

class Test::Unit::TestCase
  def setup_stubs
    stubs = {
      'http://tinyurl.com/yc7t8bv'                         => fixture('me.svenfuchs.json'),
      'http://api.twitter.com/1/users/show/svenfuchs.json' => fixture('twitter.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenfuchs'  => fixture('github.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenphoox'  => fixture('github.svenphoox.json')
    }
    stubs.each { |url, json| HTTParty.stubs(:get).with(url).returns(JSON.parse(json)) }
  end

  def fixture(filename)
    File.read(File.expand_path("../fixtures/#{filename}", __FILE__))
  end
end
