# check twitter timeline for new replies
# process replies
# store processed tweet ids
# store ping timestamp

require 'twibot'

class Identity::Poller::Twitter < Twibot::Bot
  def initialize(options = {}, prompt = false)
    # we're only interested in new replies
    raise "gotta set the :process => since_twitter_id option" unless options.key?(:process)
    
    # we only poll once, so we don't want an interval
    options.merge!(:min_interval => 0, :max_interval => 0)
    
    # otherwise use defaults
    super(Twibot::Config.default << options) # Twibot::FileConfig.new

    # add a twitter handler
    Identity::Listener::Twitter.new(self)
  end

  def receive_replies
    # abort after having received stuff once
    super.tap { @abort = true }
  end
end
