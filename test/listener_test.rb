require File.expand_path('../test_helper', __FILE__)

class ListenerTwitterTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
  end

  def update!(from, message)
    message  = message(from, message)
    listener = Identity::Listener::Twitter.new(/#update/, :update)
    listener.dispatch(message)
  end

  def message(from, message)
    Twitter::Status.new(:user => sender(from), :text => message)
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
end

