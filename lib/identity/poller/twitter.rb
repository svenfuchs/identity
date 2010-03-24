# checks for new replies only once

require 'twibot'

class Identity::Poller::Twitter < Twibot::Bot
  def initialize(type, pattern, callback, options = {})
    # we're only interested in new replies
    raise "gotta set the :process => since_twitter_id option" unless options.key?(:process)
    
    # we only poll once, so we don't want an interval
    options.merge!(:min_interval => 0, :max_interval => 0)
    
    # otherwise use defaults
    super(Twibot::Config.default << options) # Twibot::FileConfig.new

    # add a twitter handler
    add_handler(type, Identity::Listener::Twitter.new(options[:login], pattern, callback))
  end

  def receive_replies
    # abort after having received stuff once
    super.tap { @abort = true }
  end
end
