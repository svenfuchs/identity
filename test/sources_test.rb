require File.expand_path('../test_helper', __FILE__)

class SourcesTest < Test::Unit::TestCase
  def setup
    setup_stubs
  end
  
  test "update_all given a named source argument updates the identity from that source" do
    identity = Identity.new
    Identity::Sources['twitter'].expects(:update).with(identity, 'svenfuchs')
    Identity::Sources.update_all(identity, ['twitter:svenfuchs'])
  end
  
  test "update_all given a url argument updates the identity from that source" do
    identity = Identity.new
    Identity::Sources['twitter'].expects(:update).with(identity, 'svenfuchs')
    Identity::Sources.update_all(identity, ['http://twitter.com/svenfuchs'])
  end
  
  test "updating an identity from twitter polls profile data from twitter" do
    identity = Identity.new
    Identity::Sources['twitter'].update(identity, 'svenfuchs')
    assert_equal profile('twitter', 'svenfuchs'), identity.twitter
  end
  
  test "updating an identity from github polls profile data from github" do
    identity = Identity.new
    Identity::Sources['github'].update(identity, 'svenfuchs')
    assert_equal profile('github', 'svenfuchs'), identity.github
  end
  
  test "updating an identity from json polls profile data from a json file AND updates all other profiles" do
    identity = Identity.new
    Identity::Sources['json'].update(identity, 'http://tinyurl.com/yc7t8bv')
    
    assert_equal profile('json', 'svenfuchs'),    identity.json
    assert_equal profile('github', 'svenphoox'),  identity.github
    assert_equal profile('twitter', 'svenfuchs'), identity.twitter
  end
end