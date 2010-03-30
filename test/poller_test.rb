# require File.expand_path('../test_helper', __FILE__)
# require 'stringio'
# 
# class PollerTest < Test::Unit::TestCase
#   def setup
#     setup_stubs
#   end
# 
#   def process!(from, message, id = '12345')
#     status = twitter_status(from, message, id)
#     bot = Command::Poller::Twitter.new(:reply, 'rugb_test', 'password')
#     bot.handler('rugb_test').dispatch(status)
#   end
# 
#   test "polls from twitter once and handles new replies by queueing commands" do
#     Command::Message.stubs(:max_message_id).returns(12345)
#     poller = Command::Poller::Twitter.new(:reply, 'rugb_test', 'password')
# 
#     replies = [twitter_status('svenfuchs', '@rugb_test !update')]
#     poller.twitter.expects(:status).with(:replies, { :since_id => 12345 }).returns(replies)
# 
#     message = { :message_id => '12345', :receiver => 'rugb_test', :sender => 'svenfuchs', :text => '@rugb_test !update', :source => 'twitter' }
#     Command.expects(:queue).with('rugb_test', message)
#     log = capture_stdout { poller.run! }
# 
#     assert_match /imposing as @rugb_test/, log
#     assert_match /Received 1 reply/, log
#   end
# 
#   test 'updating w/ a me url and a github handle' do
#     process!('svenfuchs', '!update json:http://tinyurl.com/yc7t8bv github:svenphoox')
#     identity = Identity.find_by_handle('svenphoox')
# 
#     assert_equal 'svenphoox', identity.github['handle']
#     assert_equal 'Sven',      identity.github['name']
#   end
# 
#   test 'updating an existing profile' do
#     process!('svenfuchs', '!create', '12345')
#     assert Identity.find_by_handle('svenfuchs')
# 
#     process!('svenfuchs', '!update json:http://tinyurl.com/yc7t8bv', '12346')
#     identity = Identity.find_by_handle('svenfuchs')
# 
#     assert_equal 'svenfuchs',  identity.twitter['handle']
#     assert_equal 'Sven Fuchs', identity.twitter['name']
#     assert_equal 'svenfuchs',  identity.json['irc']
#   end
# 
#   test 'logs processed messages' do
#     now = Time.now
#     Time.stubs(:now).returns(now)
# 
#     process!('svenfuchs', '!update')
#     Identity.find_by_handle('svenfuchs')
#     message = Command::Message.find_by_message_id('12345')
# 
#     assert_equal 'rugb_test', message.receiver
#     assert_equal 'svenfuchs', message.sender
#     assert_equal '!update',   message.text
#     assert_equal '12345',     message.message_id
#     assert_equal now.to_s,    Time.parse(message.received_at).to_s
#   end
# 
#   test 'does not process an already processed message' do
#     process!('svenfuchs', '!update')
#     Identity.find_by_handle('svenfuchs')
# 
#     Command.expects(:new).never # TODO
#     Identity.find_by_handle('svenfuchs')
#   end
# 
# end