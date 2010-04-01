$: << File.expand_path('../..', __FILE__)
$: << File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'rack/test'
require 'mocha'
require 'twibot'

require 'command'
require 'identity'

require 'test/test_declarative'
require 'test/stubs/profiles'

CouchPotato::Config.database_name = "http://localhost:5984/identity"

class Test::Unit::TestCase
  def setup_stubs
    stubs = {
      'http://tinyurl.com/yc7t8bv'                         => response('json.svenfuchs.json'),
      'http://api.twitter.com/1/users/show/svenfuchs.json' => response('twitter.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenfuchs'  => response('github.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenphoox'  => response('github.svenphoox.json')
    }
    stubs.each do |url, json|
      Identity::Sources::Base.stubs(:get).with(url).returns(JSON.parse(json))
    end
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
    Command::Message.all.each { |message| message.delete }
  end

  def response(filename)
    File.read(File.expand_path("../stubs/#{filename}", __FILE__))
  end

  def profile(profile_name, handle)
    PROFILES[handle][profile_name]
  end

  def command(sender, text = '', source = 'twitter')
    text.gsub!(/^(@[\S]*) /, '')
    receiver = $1
    message = msg(12345, text, sender, receiver, source)
    command, args = *message.parse.first
    Identity::Command.new(command, args, message)
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

  def assert_profiles(handle, *profile_names)
    options = profile_names.last.is_a?(Hash) ? profile_names.pop : { :claimed_at => @now }
    profile_names.each { |profile_name| assert_profile(handle, profile_name, options) }
  end

  def assert_profile(handle, profile_name, options = { :claimed_at => @now })
    identity = Identity.find_by_handle(handle)
    assert identity.profiles.key?(profile_name), "expected a #{profile_name} profile to be contained in #{identity.profiles.inspect}"

    profile = identity.profiles[profile_name]
    assert_equal @now.to_s, Time.parse(profile.delete('claimed_at')).to_s
    assert_equal profile(profile_name, handle), profile
  end
end
