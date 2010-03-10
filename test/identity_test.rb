require File.expand_path('../test_helper', __FILE__)

class IdentityTest < Test::Unit::TestCase
  def setup
    stubs = {
      'http://tinyurl.com/yc7t8bv'                         => fixture('me.svenfuchs.json'),
      'http://api.twitter.com/1/users/show/svenfuchs.json' => fixture('twitter.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenfuchs'  => fixture('github.svenfuchs.json'),
      'http://github.com/api/v2/json/user/show/svenphoox'  => fixture('github.svenphoox.json')
    }
    stubs.each { |url, json| HTTParty.stubs(:get).with(url).returns(JSON.parse(json)) }
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
  end

  def update!(from, message)
    message = message(from, message)
    handler = Identity::Sources::Twitter.handler(/#update/, :update)
    handler.dispatch(message)
  end

  def message(from, message)
    Twitter::Message.new(:sender => sender(from), :text => message)
  end

  def sender(name)
    Twitter::User.new(:screen_name => name)
  end

  test '#parse_args parses a tweet for foo:bar arguments' do
    args = Identity.parse_args('github:foo me:http://tinyurl.com/yc7t8bv')
    assert_equal args, {'github' => 'foo', 'me' => 'http://tinyurl.com/yc7t8bv'}

    args = Identity.parse_args('me foo')
    assert_equal({}, args)
  end

  test 'updating through twitter' do
    update!('svenfuchs', '@rug_b #update')
    identity = Identity.find_by_handle('svenfuchs')

    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Sven Fuchs', identity.twitter['name']
  end

  test 'updating through twitter using me:http://tinyurl.com/yc7t8bv' do
    update!('svenfuchs', '@rug_b #update me:http://tinyurl.com/yc7t8bv')
    identity = Identity.find_by_handle('svenphoox')

    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Sven Fuchs', identity.twitter['name']
    assert_equal 'svenphoox',  identity.github['handle']
    assert_equal 'Sven',       identity.github['name']
  end

  test 'updating through twitter using github:svenfuchs' do
    update!('svenfuchs', '@rug_b #update github:svenfuchs')
    identity = Identity.find_by_handle('svenfuchs')

    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Sven Fuchs', identity.twitter['name']
    assert_equal 'svenfuchs',  identity.github['handle']
    assert_equal 'Sven Fuchs', identity.github['name']
  end

  test 'updating through twitter using github:svenphoox' do
    update!('svenfuchs', '@rug_b #update github:svenphoox')
    identity = Identity.find_by_handle('svenfuchs')

    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Sven Fuchs', identity.twitter['name']
    assert_equal 'svenphoox',  identity.github['handle']
    assert_equal 'Sven',       identity.github['name']
  end

  test 'updating adds a claimed_at time to source data when the source was first claimed' do
    Time.stubs(:now).returns(Time.local(2010, 1, 1, 12, 0, 0))
    claimed_at = Time.now
    update!('svenfuchs', '@rug_b #update')
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'Fri, 01 Jan 2010 12:00:00 +0100', identity.twitter['claimed_at']

    Time.stubs(:now).returns(Time.local(2010, 1, 2, 12, 0, 0))
    update!('svenfuchs', '@rug_b #update github:svenfuchs')
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'Fri, 01 Jan 2010 12:00:00 +0100', identity.twitter['claimed_at']
    assert_equal 'Sat, 02 Jan 2010 12:00:00 +0100', identity.github['claimed_at']
  end
end

