require File.expand_path('../../test_helper', __FILE__)

class CommandCreateTest < Test::Unit::TestCase
  def setup
    setup_stubs
    @now = Time.now
    Time.stubs(:now).returns(@now)
  end

  test '!create (w/o arguments) polls the twitter profile' do
    command('svenfuchs', '@rugb !create').run
    assert_profile('svenfuchs', 'twitter', :claimed_at => @now)
  end

  test '!create twitter:svenfuchs polls the twitter profile, same shit' do
    command('svenfuchs', '@rugb !create').run
    assert_profile('svenfuchs', 'twitter', :claimed_at => @now)
  end

  test '!create github:svenfuchs polls the twitter and github profiles' do
    command('svenfuchs', '@rugb !create github:svenfuchs').run
    assert_profile('svenfuchs', 'twitter', :claimed_at => @now)
    assert_profile('svenfuchs', 'github', :claimed_at => @now)
  end

  test '!create http://github.com/svenfuchs polls the twitter and github profiles' do
    command('svenfuchs', '@rugb !create http://github.com/svenfuchs').run
    assert_profile('svenfuchs', 'twitter', :claimed_at => @now)
    assert_profile('svenfuchs', 'github', :claimed_at => @now)
  end

  test '!create http://tinyurl.com/yc7t8bv polls the twitter and json profiles AND updates from github BUT NOT twitter' do
    source_url = Identity::Sources['github'].source_url('hax')
    Identity::Sources::Base.expects(:get).with(source_url).never

    command('svenfuchs', '@rugb !create http://tinyurl.com/yc7t8bv').run
    assert_profile('svenfuchs', 'twitter', :claimed_at => @now)
    assert_profile('svenfuchs', 'json', :claimed_at => @now)
    assert_profile('svenphoox', 'github', :claimed_at => @now)
  end
end