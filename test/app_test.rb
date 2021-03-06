require File.expand_path('../test_helper', __FILE__)

require 'app'

set :environment, :test

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def setup
    setup_stubs
  end

  test '/ping is protected through http auth' do
    Command::Poller::Twitter.stubs(:new).returns(Object.new.tap { |o| o.stubs(:run!) })
    authorized_get '/ping'
    assert_equal 200, last_response.status

    unauthorized_get '/ping'
    assert_equal 401, last_response.status
  end

  test '/ping is runs a twitter poller' do
    Command::Message.stubs(:max_message_id).returns(12345)
    poller = Command::Poller::Twitter.new(:reply, 'login', 'password')
    Command::Poller::Twitter.stubs(:new).returns(poller)
    poller.twitter.expects(:timeline_for).with(:replies, :since_id => 12345).returns([twitter_status('svenfuchs', '!update')])

    log = capture_stdout { authorized_get '/ping' }

    assert_match /imposing as @login/, log
    assert_match /Received 1 reply/, log
  end
  
  test '/ responding to :html' do
    setup_stubs
    command('rugb', 'svenfuchs', '!create twitter:svenfuchs github:svenphoox').run
    get '/'

    assert_equal 'text/html', last_response['Content-Type']
    assert_match /svenfuchs/, last_response.body # TODO use some tag matcher
  end
  
  test '/ responding to :json' do
    Identity.new(:twitter => { :handle => 'svenfuchs' }).save
    get '/', {}, { 'HTTP_ACCEPT' => 'application/json' }

    assert_equal 'application/json', last_response['Content-Type']
    assert_equal({ 'twitter' => { 'handle' => 'svenfuchs' } }, JSON.parse(last_response.body).first['profiles'])
  end
  
  protected

    def app
      Sinatra::Application
    end
  
    def authorized_get(path)
      get path, {}, { 'HTTP_AUTHORIZATION' => encode_credentials(ENV['twitter_login'], ENV['twitter_password']) }
    end
  
    def unauthorized_get(path)
      get path, {}, { 'HTTP_AUTHORIZATION' => encode_credentials('go', 'away') }
    end

    def encode_credentials(username, password)
      "Basic " + Base64.encode64("#{username}:#{password}")
    end
end