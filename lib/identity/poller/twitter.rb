# checks for new replies only once

require 'twibot'

class Identity::Poller::Twitter < Twibot::Bot
  attr_reader :receiver, :type, :pattern, :callback, :options

  def initialize(type, pattern, callback, options = {})
    raise "gotta set the :process => since_twitter_id option" unless options.key?(:process)

    # we only poll once, so we don't want an interval
    options.merge!(:min_interval => 0, :max_interval => 0)
    super(Twibot::Config.default << options) # Twibot::FileConfig.new
    
    @receiver, @type, @pattern, @callback, @options = options[:login], type, pattern, callback, options

    add_handler(type, handler)
  end

  def handler
    Twibot::Handler.new(pattern) do |message, args|
      Identity::Message.if_unprocessed(receiver, message) do
        sender = message.user.screen_name
        text   = "twitter:#{sender} #{message.text}"
        Identity::Command.new(callback, receiver, sender, text).queue
      end
    end
  end

  def receive_replies
    # abort after having received stuff once
    super.tap { @abort = true }
  end
end
