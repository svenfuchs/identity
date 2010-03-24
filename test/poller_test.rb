require File.expand_path('../test_helper', __FILE__)
require 'stringio'

class PollerTest < Test::Unit::TestCase
  def tweet(from, text)
    Twitter::Status.new(
      :id         => 1,
      :text       => text,
      :user       => Twitter::User.new(:screen_name => from),
      :created_at => Time.now
    )
  end
  
  def capture_stdout
    @stdout, $stdout = $stdout, (io = StringIO.new)
    yield
    $stdout = @stdout
    io.string
  end
  
  test "Poller::Twitter polls from twitter once and handles new replies by queueing commands" do
    config = { :login => 'svenfuchs', :process => 10623176300 }
    poller = Identity::Poller::Twitter.new(:reply, /#update/, :update, config)

    replies = [tweet('johndoe', '@svenfuchs #update')]
    poller.twitter.expects(:status).with(:replies, { :since_id => 10623176300 }).returns(replies)
    
    args = [:update, 'svenfuchs', 'johndoe', 'twitter:johndoe @svenfuchs #update']
    command = Identity::Command.new(*args)
    command.stubs(:queue)
    Identity::Command.expects(:new).with(*args).returns(command)

    log = capture_stdout { poller.run! }

    assert_match /imposing as @svenfuchs/, log
    assert_match /Received 1 reply/, log
  end
end