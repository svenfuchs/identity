require File.expand_path('../test_helper', __FILE__)

class CommandTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end

  def teardown
    Identity.all.each { |identity| identity.delete }
  end

  def update!(handle, message)
    Identity::Command.new('update', handle, message).dispatch
  end

  test '#parse_args parses a message for foo:bar arguments' do
    cmd = Identity::Command.new('update', 'svenfuchs', 'github:foo me:http://tinyurl.com/yc7t8bv')
    assert_equal cmd.args, {'github' => 'foo', 'me' => 'http://tinyurl.com/yc7t8bv'}

    cmd = Identity::Command.new('update', 'svenfuchs', 'me foo')
    assert_equal({}, cmd.args)
  end

  test 'updating w/ a twitter handle' do
    update!('svenfuchs', 'twitter:svenfuchs')

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Berlin',     identity.twitter['location']
  end

  test 'updating w/ a github handle' do
    update!('svenfuchs', 'github:svenfuchs')

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs',  identity.github['handle']
  end

  test 'updating w/ a me url' do
    update!('svenfuchs', 'me:http://tinyurl.com/yc7t8bv')
    identity = Identity.find_by_handle('svenphoox')
    assert_equal 'svenphoox',  identity.github['handle']
    assert_equal 'Sven',       identity.github['name']
  end

  test 'updating adds a claimed_at time to source data when the source was first claimed' do
    twitter_at = Time.local(2010, 1, 1, 12, 0, 0)
    github_at  = Time.local(2010, 1, 2, 12, 0, 0)
    Time.stubs(:now).returns(twitter_at)

    update!('svenfuchs', 'twitter:svenfuchs')
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal twitter_at, Time.parse(identity.twitter['claimed_at'])

    Time.stubs(:now).returns(Time.local(2010, 1, 2, 12, 0, 0))
    update!('svenfuchs', 'github:svenfuchs')
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal twitter_at, Time.parse(identity.twitter['claimed_at'])
    assert_equal github_at,  Time.parse(identity.github['claimed_at'])
  end

end
