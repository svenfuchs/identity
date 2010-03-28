$: << File.expand_path('../..', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'rack/test'
require 'mocha'
require 'twibot'
require File.expand_path('../test_declarative', __FILE__)

require 'command'
require 'identity'

CouchPotato::Config.database_name = "http://localhost:5984/identity"

class Test::Unit::TestCase
  def setup_stubs
    stubs = {
      'http://tinyurl.com/yc7t8bv'                         => response('me.svenfuchs.json'),
      'http://api.twitter.com/1/users/show/svenfuchs.json' => response('twitter.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenfuchs'  => response('github.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenphoox'  => response('github.svenphoox.json')
    }
    stubs.each { |url, json| Identity::Sources::Base.stubs(:get).with(url).returns(JSON.parse(json)) }
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
    Command::Message.all.each { |message| message.delete }
  end

  def response(filename)
    File.read(File.expand_path("../stubs/#{filename}", __FILE__))
  end

  def command(type, receiver, sender, text = '', source = 'twitter')
    Command.new(type, msg(12345, text, sender, receiver, source))
  end
  
  def msg(id = 12345, text = 'text', sender = 'sender', receiver = 'receiver', source = 'twitter')
    Command::Message.create :message_id  => id,
                            :text        => text,
                            :sender      => sender,
                            :receiver    => receiver,
                            :source      => source,
                            :received_at => Time.now
  end

  def twitter_status(from, message, id = '12345')
    Twitter::Status.new(:id => id, :user => twitter_sender(from), :text => message, :created_at => Time.now)
  end

  def twitter_sender(name)
    Twitter::User.new(:screen_name => name)
  end
  
  def capture_stdout
    @stdout, $stdout = $stdout, (io = StringIO.new)
    yield
    $stdout = @stdout
    io.string
  end
end
