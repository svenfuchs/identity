$: << File.expand_path('../..', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'rack/test'
require 'mocha'
require 'twibot'
require File.expand_path('../test_declarative', __FILE__)

require 'identity'

CouchPotato::Config.database_name = "http://localhost:5984/identity"

class Test::Unit::TestCase
  def setup_stubs
    stubs = {
      'http://tinyurl.com/yc7t8bv'                         => fixture('me.svenfuchs.json'),
      'http://api.twitter.com/1/users/show/svenfuchs.json' => fixture('twitter.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenfuchs'  => fixture('github.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenphoox'  => fixture('github.svenphoox.json')
    }
    stubs.each { |url, json| Identity::Sources::Base.stubs(:get).with(url).returns(JSON.parse(json)) }
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
    Identity::Message.all.each { |message| message.delete }
  end

  def fixture(filename)
    File.read(File.expand_path("../fixtures/#{filename}", __FILE__))
  end

  def command(command, receiver, sender, message)
    Identity::Command.new(command, receiver, sender, message)
  end

  def status(from, message, id = '12345')
    Twitter::Status.new(:id => id, :user => sender(from), :text => message)
  end

  def sender(name)
    Twitter::User.new(:screen_name => name)
  end
  
  def capture_stdout
    @stdout, $stdout = $stdout, (io = StringIO.new)
    yield
    $stdout = @stdout
    io.string
  end
end
