# checks for new replies only once

require 'twibot'

class Identity::Poller::Twitter < Twibot::Bot
  def initialize(type, login, password)
    # we only poll once, so we don't want an interval
    options = { 
      :login        => login, 
      :password     => password,
      :min_interval => 0, 
      :max_interval => 0,
      :process      => Identity::Message.max_message_id
    }
    super(Twibot::Config.default << options)

    add_handler(type, handler(login))
  end

  def handler(receiver)
    Twibot::Handler.new('!([\w]+)') do |message, *args|
      Identity::Command.queue(receiver, 
        :receiver   => receiver,
        :message_id => message.id,
        :sender     => message.user.screen_name,
        :text       => message.text,
        :source     => 'twitter'
      )
    end
  end

  def receive_replies
    # abort after having received stuff once
    super.tap { @abort = true }
  end
end
