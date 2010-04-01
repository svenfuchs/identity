require File.expand_path('../../test_helper', __FILE__)

class CommandUpdateExistingTest < Test::Unit::TestCase
  def setup
    setup_stubs
    @now = Time.now
    Time.stubs(:now).returns(@now)

    Identity.create(
      :json    => profile('json',    'svenfuchs').merge(:email => 'will_be_overwritten'),
      :twitter => profile('twitter', 'svenfuchs').merge(:name  => 'will_be_overwritten'),
      :github  => profile('github',  'svenfuchs').merge(:name  => 'will_be_overwritten')
    )
  end

  test '!update updates all known profiles' do
    command('svenfuchs', '@rugb !update').run
    assert_profiles('svenfuchs', 'twitter', 'json')
    assert_profile('svenphoox', 'github')
  end

  test '!update twitter:svenfuchs updates the twitter profile' do
    command('svenfuchs', '@rugb !update twitter:svenfuchs').run
    assert_profile('svenfuchs', 'twitter')
  end
  
  test '!update github:svenfuchs updates the github profile' do
    command('svenfuchs', '@rugb !update github:svenfuchs').run
    assert_profile('svenfuchs', 'github')
  end
  
  test '!update http://github.com/svenfuchs updates the github profile' do
    command('svenfuchs', '@rugb !update http://github.com/svenfuchs').run
    assert_profile('svenfuchs', 'github')
  end
  
  test '!update http://tinyurl.com/yc7t8bv updates the json profiles AND updates from github BUT NOT twitter' do
    source_url = Identity::Sources['github'].source_url('hax')
    Identity::Sources::Base.expects(:get).with(source_url).never
  
    command('svenfuchs', '@rugb !update http://tinyurl.com/yc7t8bv').run
    assert_profiles('svenfuchs', 'json')
    assert_profile('svenphoox', 'github')
  end
end