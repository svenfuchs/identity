require File.expand_path('../test_helper', __FILE__)

class CouchTest < Test::Unit::TestCase
  test "find_by_handle finds a single record that has the given handle in one of the sources" do
    identity = Identity.new
    identity.sources = { 'twitter' => { 'handle' => 'svenfuchs' }, 'github' => { 'handle' => 'svenphooks' } }
    identity.save
    
    result = Identity.find_by_handle('svenfuchs')

    id = identity.id
    identity.delete
    
    assert_equal id, result.id
    assert_equal identity.sources, result.sources
  end
end