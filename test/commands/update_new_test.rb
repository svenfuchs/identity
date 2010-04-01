require File.expand_path('../../test_helper', __FILE__)

class CommandUpdateNewTest < Test::Unit::TestCase
  def setup
    setup_stubs
    @now = Time.now
    Time.stubs(:now).returns(@now)
  end

  test '!update (w/o arguments) polls the twitter profile' do
    command('svenfuchs', '@rugb !update').run
    assert_profile('svenfuchs', 'twitter')
  end

  test '!update twitter:svenfuchs polls the twitter profile' do
    command('svenfuchs', '@rugb !update twitter:svenfuchs').run
    assert_profile('svenfuchs', 'twitter')
  end
  
  test '!update github:svenfuchs polls the twitter and github profiles' do
    command('svenfuchs', '@rugb !update github:svenfuchs').run
    assert_profiles('svenfuchs', 'twitter', 'github')
  end
  
  test '!update http://github.com/svenfuchs polls the twitter and github profiles' do
    command('svenfuchs', '@rugb !update http://github.com/svenfuchs').run
    assert_profiles('svenfuchs', 'twitter', 'github')
  end
  
  test '!update http://tinyurl.com/yc7t8bv polls the twitter and json profiles AND updates from github BUT NOT twitter' do
    source_url = Identity::Sources['github'].source_url('hax')
    Identity::Sources::Base.expects(:get).with(source_url).never
  
    command('svenfuchs', '@rugb !update http://tinyurl.com/yc7t8bv').run
    assert_profiles('svenfuchs', 'twitter', 'json')
    assert_profile('svenphoox', 'github')
  end
end

