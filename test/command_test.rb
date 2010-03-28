require File.expand_path('../test_helper', __FILE__)

class CommandTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end

  test '#arguments' do
    cmd = command('create', 'rugb', 'svenfuchs', 'github:foo json:http://tinyurl.com/yc7t8bv')
    assert_equal(['github:foo', 'json:http://tinyurl.com/yc7t8bv'], cmd.arguments)

    cmd = command('create', 'rugb', 'svenfuchs', 'me foo')
    assert_equal([], cmd.arguments)
  end

  test 'creating w/ a twitter handle' do
    command('create', 'rugb', 'svenfuchs', 'twitter:svenfuchs').dispatch

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs',  identity.twitter['handle']
    assert_equal 'Berlin',     identity.twitter['location']
  end

  test 'creating w/ a github handle' do
    command('create', 'rugb', 'svenfuchs', 'github:svenfuchs').dispatch

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs', identity.github['handle']
  end

  test 'creating w/ a json url' do
    command('create', 'rugb', 'svenfuchs', 'json:http://tinyurl.com/yc7t8bv').dispatch

    identity = Identity.find_by_handle('svenphoox')
    assert_equal 'svenphoox', identity.github['handle']
    assert_equal 'Sven',      identity.github['name']
  end

  test 'creating w/ a github url' do
    command('create', 'rugb', 'svenfuchs', 'http://github.com/svenfuchs').dispatch

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs', identity.github['handle']
  end

  test 'creating w/ a twitter url' do
    command('create', 'rugb', 'svenfuchs', 'http://twitter.com/svenfuchs').dispatch

    identity = Identity.find_by_handle('svenfuchs')
    assert_equal 'svenfuchs', identity.twitter['handle']
  end

  test 'creating w/ a url returning json' do
    command('create', 'rugb', 'svenfuchs', 'http://tinyurl.com/yc7t8bv').dispatch

    identity = Identity.find_by_handle('svenphoox')
    assert_equal 'svenphoox', identity.github['handle']
    assert_equal 'Sven',      identity.github['name']
  end

  test 'creating adds a claimed_at time to source data when the source was first claimed' do
    twitter_at = Time.local(2010, 1, 1, 12, 0, 0)
    github_at  = Time.local(2010, 1, 2, 12, 0, 0)
    Time.stubs(:now).returns(twitter_at)

    command('create', 'rugb', 'svenfuchs', 'twitter:svenfuchs').dispatch
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal twitter_at, Time.parse(identity.twitter['claimed_at'])

    Time.stubs(:now).returns(Time.local(2010, 1, 2, 12, 0, 0))
    command('update', 'rugb', 'svenfuchs', 'github:svenfuchs').dispatch
    identity = Identity.find_by_handle('svenfuchs')
    assert_equal twitter_at, Time.parse(identity.twitter['claimed_at'])
    assert_equal github_at,  Time.parse(identity.github['claimed_at'])
  end

  test 'joining a group' do
    command('create', 'rugb', 'svenfuchs').dispatch
    command('join', 'rugb', 'svenfuchs', 'twitter:svenfuchs').dispatch

    identity = Identity.find_by_handle('svenfuchs')
    assert identity.groups.include?('rugb')
  end

end
