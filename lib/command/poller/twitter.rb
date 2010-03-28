# checks for new replies only once

require 'twibot'

class Command::Poller::Twitter < Twibot::Bot
  def initialize(type, login, password)
    super(Twibot::Config.default << {
      :login        => login, 
      :password     => password,
      :process      => Command::Message.max_message_id,
      :min_interval => 0,
      :max_interval => 0
    })

    add_handler(type, handler(login))
  end

  def handler(receiver)
    Twibot::Handler.new(Command::Message::COMMAND_PATTERN) do |message, *args|
      Command.queue(receiver,
        :receiver   => receiver,
        :message_id => message.id,
        :sender     => message.user.screen_name,
        :text       => message.text,
        :source     => 'twitter'
      )
    end
  end
  
  def receive_messages
    super.tap { @abort = true } # we only poll once
  end

  def receive_replies
    super.tap { @abort = true } # we only poll once
  end
end
