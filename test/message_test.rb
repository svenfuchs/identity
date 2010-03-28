require File.expand_path('../test_helper', __FILE__)

class MessageTwitterTest < Test::Unit::TestCase
  test "max_message_id returns the latest message_id" do
    %w(12345 12346 12347 12348).each { |id| msg(id).save }
    assert_equal 12348, Identity::Message.max_message_id
  end
end