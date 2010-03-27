require File.expand_path('../test_helper', __FILE__)
require 'stringio'

class PollerTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end

  def update!(from, message, id = '12345')
    status  = status(from, message, id)
    bot = Identity::Poller::Twitter.new(:reply, /!update/, :update, :login => 'rugb_test', :process => 10623176300)
    bot.handler.dispatch(status)
  end

  test "polls from twitter once and handles new replies by queueing commands" do
    config = { :login => 'svenfuchs', :process => 10623176300 }
    poller = Identity::Poller::Twitter.new(:reply, /!update/, :update, config)

    replies = [status('johndoe', '@svenfuchs !update')]
    poller.twitter.expects(:status).with(:replies, { :since_id => 10623176300 }).returns(replies)

    args = [:update, 'svenfuchs', 'johndoe', 'twitter:johndoe @svenfuchs !update']
    command = Identity::Command.new(*args)
    command.stubs(:queue)
    Identity::Command.expects(:new).with(*args).returns(command)

    log = capture_stdout { poller.run! }

    assert_match /imposing as @svenfuchs/, log
    assert_match /Received 1 reply/, log
  end

  test 'updating w/ a me url and a github handle' do
    update!('svenfuchs', '!update json:http://tinyurl.com/yc7t8bv github:svenphoox')
    identity = Identity.find_by_handle('svenphoox')

    assert_equal 'svenphoox', identity.github['handle']
    assert_equal 'Sven',      identity.github['name']
  end

  test 'updating an existing profile' do
    update!('svenfuchs', '!update github:svenphoox')
    assert !Identity.find_by_handle('svenphoox').nil?

    update!('svenfuchs', '!update json:http://tinyurl.com/yc7t8bv', '12346')
    identity = Identity.find_by_handle('svenphoox')

    assert_equal 'svenphoox', identity.github['handle']
    assert_equal 'Sven',      identity.github['name']
    assert_equal 'svenfuchs', identity.json['irc']
  end

  test 'logs processed messages' do
    now = Time.now
    Time.stubs(:now).returns(now)

    update!('svenfuchs', '!update')
    Identity.find_by_handle('svenfuchs')
    message = Identity::Message.find_by_message_id('12345')

    assert_equal 'rugb_test', message.receiver
    assert_equal 'svenfuchs', message.sender
    assert_equal '!update',   message.text
    assert_equal '12345',     message.message_id
    assert_equal now.to_s,    Time.parse(message.received_at).to_s
  end

  test 'does not process an already processed message' do
    update!('svenfuchs', '!update')
    Identity.find_by_handle('svenfuchs')

    Identity::Command.expects(:new).never
    Identity.find_by_handle('svenfuchs')
  end

end