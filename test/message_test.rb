require File.expand_path('../test_helper', __FILE__)

class MessageTwitterTest < Test::Unit::TestCase
  def teardown
    # Identity::Message.all.each { |message| message.delete }
  end

  def message(id, text = 'da message', sender = 'svenfuchs', receiver = 'rugb_test')
    Identity::Message.new :message_id  => id,
                          :text        => text,
                          :sender      => sender,
                          :receiver    => receiver,
                          :received_at => Time.now
  end
  
  test "max_message_id returns the latest message_id" do
    %w(12345 12346 12347 12348).each { |id| message(id).save }
    assert_equal 12348, Identity::Message.max_message_id
  end
end