require File.expand_path('../test_helper', __FILE__)

class ListenerTwitterTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
    Identity::Message.all.each { |message| message.delete }
  end

  def update!(from, message, id = '12345')
    message  = message(from, message, id)
    listener = Identity::Listener::Twitter.new('rugb_test', /#update/, :update)
    listener.dispatch(message)
  end

  def message(from, message, id = '12345')
    Twitter::Status.new(:id => id, :user => sender(from), :text => message)
  end

  def sender(name)
    Twitter::User.new(:screen_name => name)
  end

  test 'updating w/ a me url and a github handle' do
    update!('svenfuchs', '#update me:http://tinyurl.com/yc7t8bv github:svenphoox')
    identity = Identity.find_by_handle('svenphoox')

    assert_equal 'svenphoox',  identity.github['handle']
    assert_equal 'Sven',       identity.github['name']
  end

  test 'updating an existing profile' do
    update!('svenfuchs', '#update github:svenphoox')
    assert !Identity.find_by_handle('svenphoox').nil?

    update!('svenfuchs', '#update me:http://tinyurl.com/yc7t8bv', '12346')
    identity = Identity.find_by_handle('svenphoox')

    assert_equal 'svenphoox', identity.github['handle']
    assert_equal 'Sven',      identity.github['name']
    assert_equal 'svenfuchs', identity.me['irc']
  end

  test 'logs processed messages' do
    now = Time.now
    Time.stubs(:now).returns(now)

    update!('svenfuchs', '#update')
    Identity.find_by_handle('svenfuchs')
    message = Identity::Message.find_by_message_id('12345')

    assert_equal 'rugb_test', message.receiver
    assert_equal 'svenfuchs', message.sender
    assert_equal '#update',   message.text
    assert_equal '12345',     message.message_id
    assert_equal now.to_s,    Time.parse(message.received_at).to_s
  end

  test 'does not process an already processed message' do
    update!('svenfuchs', '#update')
    Identity.find_by_handle('svenfuchs')

    Identity::Command.expects(:new).never
    Identity.find_by_handle('svenfuchs')
  end
end

